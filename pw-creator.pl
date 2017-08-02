#!/usr/bin/perl -w

use strict;
use warnings;

my $_rand;

my $password_length = $ARGV[0] || 24;

my @chars = split ( " ", 
"a b c d e f g h i j k l m n o p q r s t u v w x y z " . 
"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z " .
"0 1 2 3 4 5 6 7 8 9 - _ % # | ( ) [ ] { }" );

srand;

for my $i ( 1 .. 20 ) {
    my $password = "";
    for my $j ( 1 .. $password_length ) {
        $_rand = int ( rand @chars );
        $password .= $chars[$_rand];
    }
    print $password, "\n";
}
