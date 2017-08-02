#!/usr/bin/env myperl5.23

binmode STDOUT, ":encoding(UTF-8)";
autoflush STDOUT, 1;

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

use Data::Dumper;
use Storable ();
use experimental qw/smartmatch/;

sub trim {
    # trim trailing whitespaces
    my @ret = map {s/^\s+|\s+$//g; $_} @_;
    return wantarray ? @ret : shift @ret;
}

sub trim2 {
    # trim trailing apostrophes
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

    say $rss->title, ": ", scalar $rss->items;
    return 1;

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

# get all already loaded rss items
my %new = ();
my $fp  = '/home/jmark/tmp/test.storable';
my %old = -e $fp ? %{Storable::retrieve($fp)} : ();

# register rss feed urls
use HTTP::Async;
my $http = HTTP::Async->new;
$http->add(HTTP::Request->new(HEAD => $_)) for @urls;

while (my $resp = $http->wait_for_next_response) {
    my $url     = $resp->request->uri->as_string;
    my $method  = $resp->request->method;
    my $code    = $resp->code;
    my $msg     = $resp->message;
    my $hds     = $resp->headers;

    # after probing feed url fire GET request
    if ('HEAD' eq uc $header) {
        my $strId = $hds->header('etag') . $hds->last_modified;
        $new{$url} = md5_hex($strId) if $strId;
        $http->add(HTTP::Request->new(GET => $url)) 
            unless (defined $old{$url} and defined $new{$url} and $old{$url} eq $new{$url});
    } elsif ('GET' eq uc $method) {
        #say "$method $url [$code] $msg";
        #say "  hash: ", $new{$url};
        #say "   hds: ", join ", ", $hds->header_field_names;
        digest $url, $resp->decoded_content;
    }
}

Storable::store(\%new, $fp);
