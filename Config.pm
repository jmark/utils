package Config;

use v5.20;
use List::Util qw/pairmap first/;
use strict;
use warnings;

our %RX = (
    GS          => qr/\r*\n*[\-=]{2,}(?:.*?)*\r*\n+/,
    RS          => qr/(?<=[^(\\\s*)])\r*\n+/,
    FS          => qr/\s*:\s+/,
    comment     => qr!^\s*(?://|#)!,
    directive   => qr!^\s*@!,
    multiline   => qr/\\\s*\r*\n+/,
    variable    => qr/(?![^\\])?(\$\{(.*?)\})/,
);

our %VARS = %ENV;

sub trim {
    my @retval = map {;defined and s/^(\s|\r|\n)*|(\s|\r|\n)*$//gr or ''} @_;
    wantarray ? @retval : shift @retval;
}

sub apply_macros(@) {
    map {;
        m/$RX{directive}/ ? dispatch_directive($_) : apply_substitution($_);
    } @_;
}

sub apply_substitution(@) {
    my @retval = map {;
        pairmap {; 
            die "variable '$b' not defined!" unless $VARS{$b};
            s|\Q$a\E|$VARS{$b}|gr;
    } m/$RX{variable}/g;} @_;
    @retval ? @retval : @_;
}

sub dispatch_directive($) {
    my ($directive, $argument) = split /\s+/, trim(shift), 2;
    set_var($argument) if lc $directive eq '@set';
}

sub set_var($) {
    my ($name, $value) = split /\s+/, trim(shift), 2;
    ($VARS{$name}) = apply_substitution($value);
    ();
}

sub purge_lines(@) {
    grep {;$_ and not m/$RX{comment}/} @_;
}

sub parse($) {
    grep {;%$_}                     # purge 'empty' artifacts
    map {; scalar {
        trim map {;join "\n",       # trim backslashes
            map {;s/^\s*\\//r} trim map {;s/\\\s*$//r}
            split /$RX{multiline}/}
        map {;split $RX{FS}, $_, 2} # split into fields: key => value
        apply_macros
        purge_lines
        split $RX{RS}               # split into records
    }} split $RX{GS}, shift;        # split into groups
}

1;

package MAIN;

use v5.20;
use strict;
use warnings;

use Config;
use Data::Dumper;

# my @config = Config::parse q{
# @set MAILDIR    ${HOME}/foob/erer
# @set ROOT       /home/wklwer
# 
# ----------------------------
# folder  :   ${MAILDIR}/foo/ber
# Helene Fischer  : 30
# ----------------------------
# };
# 
# print Dumper \@config;

my @config = Config::parse join '', <DATA>;

print Dumper \@config;

__DATA__

@set MAILDIR    ${HOME}/foob/erer
@set ROOT       /home/wklwer

----------------------------
// some ${MAILDIR}
folder  :   ${MAILDIR}/foo/ber

----------------------------

----------------------------
// some ${MAILDIR}
Helene Fischer  : 30
Maria           : 20
Annika          : 15

----------------------------
===========

    // some comment
    Helene Fischer: 30
    Maria:          20
    Annika:         \
        Some multiline text. \
        \    and here... and there!! \
        Here comes some even more text! \
        And What else is there to say? \
        \    foreach ...\
        \        some code ..od\
        \        lwerer\
        \    end \
        ${ROOT}
----------------------------
