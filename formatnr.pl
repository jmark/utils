#!/usr/bin/env perl

use v5.20;

my $N = shift(@ARGV) || 3;
my $P = shift(@ARGV) || '0';

while(<>)
{
    chomp();
    if(/(\d+)/) {
        my @r = split /\d+/;
        my $f = sprintf '%0'.$N.'d',$1;
        $,='';
        say shift(@r),$f,@r;
    }
}
