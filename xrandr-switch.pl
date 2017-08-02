#!/usr/bin/perl
use strict;
use warnings;
use Tk;

my $mon0 = 'HDMI-0';
my $mon1 = 'DVI-0';

my @commands = (
    "/home/master/scripts/turn-off-screensaver.sh",
    "xrandr --output $mon0 --left-of $mon1",
    "xrandr --output $mon1 --right-of $mon0",
    "xrandr --output $mon1 --same-as $mon0",
    "xrandr --output $mon0 --auto",
    "xrandr --output $mon0 --off",
    "xrandr --output $mon1 --auto",
    "xrandr --output $mon1 --off",
);

my @selecText = (
    "Turn off screensaver",
    "Dual Head: $mon0 left of $mon1",
    "Dual Head: $mon1 right of $mon0",
    "Clone",
    "Turn on LEFT monitor",
    "Turn off LEFT monitor",
    "Turn on RIGHT monitor",
    "Turn off RIGHT monitor",
);

my $mw = MainWindow->new ();
$mw->title("xrandr-switch");

my $bf = $mw->fontCreate (
    'big',
    -family=>'arial',
    -weight=>'bold',
    -size=>int(-18*18/14)
);

my $lb = $mw->Listbox(-selectmode => "browse", -font => "big", -width => 50);
$lb->insert ('end', @selecText );
$lb->bind ('<Return>', \&listBoxEvent );

$lb->activate ( 0 );
$lb->selectionSet ( 0 );

$lb->focusForce;

$lb->pack();
$mw->update;     # Make sure width and height are current

#my $sw = $mw->screenwidth;
my $sw = 1920;
my $sh = $mw->screenheight;

my $xpos = int(( $sw - $mw->width ) / 2);
my $ypos = int(( $sh - $mw->height) / 2);

$mw->geometry("+$xpos+$ypos");
$mw->deiconify;
$mw->update;     # Make sure width and height are current

$mw->bind ('<Escape>', sub  { exit } );
MainLoop;

sub listBoxEvent { 
    my $index = shift @{$lb->curselection()};
    system( $commands[$index] );
    exit;
};
