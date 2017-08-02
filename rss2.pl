#!/usr/bin/env myperl5.23

binmode STDOUT, ":encoding(UTF-8)";
autoflush STDOUT, 1;

package myUA;

use Exporter();
use LWP::Parallel::UserAgent qw(:CALLBACK);

@ISA = qw(LWP::Parallel::UserAgent Exporter);
@EXPORT = @LWP::Parallel::UserAgent::EXPORT_OK;
 
# redefine methods: on_connect gets called whenever we're about to
# make a a connection
# sub on_connect {
#   my ($self, $request, $response, $entry) = @_;
#   print "Connecting to ",$request->url,"\n";
# }
 
# on_failure gets called whenever a connection fails right away
# (either we timed out, or failed to connect to this address before,
# or it's a duplicate). Please note that non-connection based
# errors, for example requests for non-existant pages, will NOT call
# on_failure since the response from the server will be a well
# formed HTTP response!
sub on_failure {
    my ($self, $request, $response, $entry) = @_;
    print "Failed to connect to ",$request->url,"\n\t", $response->code, ", ", $response->message,"\n" if $response;
    return;
}
 
# on_return gets called whenever a connection (or its callback)
# returns EOF (or any other terminating status code available for
# callback functions). Please note that on_return gets called for
# any successfully terminated HTTP connection! This does not imply
# that the response sent from the server is a success! 
sub on_return {
    my ($self, $request, $response, $entry) = @_;
    print $request->url," [", $response->code,"]: ", $response->message, "\n";
    return;
}

1;
 
package main;

use v5.22;
use Digest::MD5 qw/md5_hex/;

use Encode;
use File::Slurp qw/read_file write_file/;
use File::Path qw/make_path/;
use File::Temp qw/tempfile/;
use File::Spec::Functions qw/canonpath/;
use File::Copy qw/move/;

use XML::Feed;
use DateTime;
use DateTime::Format::Mail;
use Email::Simple;

use HTTP::Request; 
use HTTP::Date;
use LWP::Parallel::UserAgent;

use Data::Dumper;
use Storable;
use experimental qw/smartmatch/;

sub trim {
    my @ret = map {s/^\s+|\s+$//g; $_} @_;
    return wantarray ? @ret : shift @ret;
}

sub trim2 {
    my @ret = map {s/^('|")+|('|")+$//g; $_} @_;
    return wantarray ? @ret : shift @ret;
}


my $ROOT = "$ENV{HOME}/rss";
my %FEEDS = map {;split(/\s/, trim $_);} grep {;!(/#/ || /^$/);} read_file("$ROOT/feeds");

sub digest {
    my ($url, $data) = @_;
    my $rss;

    eval { $rss = XML::Feed->parse(\$data); };
    if ($@) {
        warn "[error]: $@";
        warn "  $url";
        return 0;
    }

    my $path = "$ROOT/old/".md5_hex($url);
    my %old  = map {chomp;($_,0)} read_file($path,{err_mode=>'quiet'});
    my $res  = !$rss ? -1 :
                map  {deliver($url,$_->[1]) && write_file($path,{append => 1},"$_->[0]\n")}
                grep {!defined $old{$_->[0]}}
                map  {[md5_hex(encode('ascii',$_->id.$_->link)),$_]}
                $rss->items;

    if    ($res < 0) {say "[ERROR]: $url";}
    elsif ($res > 0) {printf("\e[1;37;40m[%3d] %s\e[0m\n",$res,$rss->title);}
    else  {printf("[   ] %s\n",$rss->title);}

    return 1;
}

sub date {
    my ($item) = @_;
    sub fmt {DateTime::Format::Mail->format_datetime($_[0])};
    my $date = $item->issued;
    return defined $date ? fmt($date) : fmt(DateTime->now());
}

sub deliver {
    my ($url, $item) = @_;

    my $M = Email::Simple->create();
    $M->header_set('Subject',$item->title);
    $M->header_set('From','feedy!!');
    $M->header_set('Date', date($item));
    $M->header_set('Content-type','text/html');
    $M->header_set('Url',$item->link);

    my $furl = ref $item->unwrap eq 'HASH' ? $item->unwrap->{enclosure}->{url} : '';

    my $body = "<pre>@{[$item->summary->body]}</pre>\n<br><br>\n";
    $body .= "<a href=\"@{[$item->link]}\">Link</a>\n<br><br>\n";
    $body .= "<a href=\"$furl\">$furl</a>\n<br><br>\n" if $furl;
    $body .= "<pre>=====\n\n@{[$item->content->body]}</pre>\n";
    $M->body_set($body);

    my $dest = canonpath("$ROOT/items/$FEEDS{$url}");
    do {die unless make_path($dest)} unless -e $dest;

    my ($fh, $fn) = tempfile(DIR => $dest);
    write_file($fh,{binmode=>':utf8'},$M->as_string);
    move($fn, "$dest/".(stat $fn)[1]);

    return 1;
}

my @urls = qw(
    http://cre.fm/feed/mp3/
    http://freakshow.fm/feed/mp3
    http://opa-harald.de/feed/mp3
    http://feeds.5by5.tv/changelog
    http://soziopod.de/feed/podcast/
    http://feeds.rebuild.fm/rebuildfm
    http://www.wrint.de/feed/podcast/
    https://www.youtube.com/feeds/videos.xml?user=vice
    https://www.youtube.com/feeds/videos.xml?user=MotherboardTV
    http://www.psycho-talk.de/feed/mp3
);

#my @urls = keys %FEEDS;
#@urls = @urls[0..20];
 
my $fp = '/home/jmark/tmp/test.storable';

my $ua = LWP::Parallel::UserAgent->new();
$ua->nonblock(0);
$ua->in_order(0);
$ua->max_req(100);
$ua->max_hosts(10);

$ua->register($_) for map {;HTTP::Request->new('HEAD', $_);} @urls;

my %new = map {;
        $_->request->uri()->as_string() => {
            'etag'          => trim2($_->header('etag')) || undef,
            'last-modified' => defined $_->header('last-modified') ? str2time($_->header('last-modified')) : undef,
        }
    ;} map {;$_->response;} values %{$ua->wait()};

my %old = -e $fp ? %{retrieve($fp)} : ();

my @changed = grep {;
    my %old = %{$old{$_} // {}};
    my %new = %{$new{$_} // {}};
    not grep {;$old{$_} && $new{$_} and $old{$_} ~~ $new{$_};} qw/etag last-modified/;
;} keys %new;

#store(\%new, $fp) unless -e $fp;

$ua->initialize();
$ua->register($_) for map {;HTTP::Request->new('GET', $_);} @changed;

*{LWP::Parallel::UserAgent::on_return} = sub {
    my ($self, $request, $response, $entry) = @_;
    say $request->url, " ", $response->code,": ", $response->message;
};

my %rss = map {;
        $_->request->uri()->as_string() => 
        $_->decoded_content()
    ;} map {;$_->response;} values %{$ua->wait()};

#say Dumper \%rss;
