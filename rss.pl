#!/usr/bin/env myperl5.22

binmode STDOUT, ":encoding(UTF-8)";
autoflush STDOUT, 1;

use v5.22;
use experimental qw/signatures postderef/;

use AnyEvent;
use AnyEvent::HTTP;

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

$AnyEvent::HTTP::TIMEOUT = 8;
$AnyEvent::HTTP::MAX_PER_HOST = 100;

my $ROOT = "$ENV{HOME}/rss";

# 'feed url' => 'folder to deliver'
my %FEEDS = map {chomp($_);split(/\s/,$_)} grep {!(/#/ || /^$/)} read_file("$ROOT/feeds");

my $JOBS;
my $finished = AnyEvent->condvar;

my @JOBS = map {
    my $U = $_; # url: neccessary in order to force new closure context
    http_get $U, sub ($B,$H) {
        $H->{Status} =~ /^2/ and digest($U,$B) or say "[error] $H->{Status} | $H->{Reason} for $U";
        $finished->send if --$JOBS == 0;
    }} keys %FEEDS;

$JOBS = @JOBS;
$finished->recv;

# =========================================================================== #

sub digest($url,$data) {
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

sub date ($item) {
    sub fmt {DateTime::Format::Mail->format_datetime($_[0])};
    my $date = $item->issued;
    return defined $date ? fmt($date) : fmt(DateTime->now());
}

sub deliver($url,$item) {

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
