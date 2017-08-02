#!/usr/bin/env perl

use strict;
use warnings;
use List::MoreUtils qw/zip/;

sub say {print @_, "\n"}
sub maxlen {
    my $max = 0;
    for my $el (@_) {
        $max = @$el > $max ? @$el : $max;
    } 
    return $max;
}

sub img {
    my $fp = shift;
    sprintf '<img class"snapshot" src="%s" />', $fp;
}

sub tbld {
    return "<td> @_ </td>";
}

sub tblr {
    return "<tr> @_ </tr>";
}

sub table {
    return "<table>\n@_\n</table>\n";
}

my @files = map {;
    my $dir = $_;
    opendir(my $dh, $dir) or die "Can't opendir $dir: $!";
    my @pngs = map {; "$dir/$_" ;} sort grep {; /\.png$/ ;} readdir($dh);
    closedir $dh;
    [@pngs];
;} @ARGV;


print "
<html>
<head>
<style>
table {
    width: 100%;
}

img {
    width: 100%;
}
</style>
</head>
<body>

<table border=\"1\">
";

for (my $i = 0; $i < maxlen @files; $i++) {
    my @pics = map {; $files[$_]->[$i] // '' ;} 0..$#files;

    print tblr(join " ", map {; tbld $_ ;} map {; img $_ ;} @pics);
    print "\n";
}

print "
</table>
</body>
</html>";
