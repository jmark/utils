#!/usr/bin/env perl

use v5.20;
use utf8;
use open qw(:std :utf8);

use File::Slurp qw/read_file write_file/;
use File::Path qw/make_path/;
use File::Temp qw/tempfile/;
use File::Spec::Functions qw/canonpath/;
use File::Copy qw/move/;

my $src  = shift @ARGV; # mbox file
my $dest = shift @ARGV; # destination dir

if (!-e $dest) {
    die unless make_path($dest);
}

my @mails = split /\nFrom:{0}\s.*?\n/,read_file($src);

say scalar @mails;

for my $mail (@mails)
{
    my ($fh, $filename) = tempfile( DIR => $dest );
    write_file($fh,$mail);

    my $inode = (stat $filename)[1];
    move($filename, canonpath("$dest/$inode"));
}
