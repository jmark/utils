#!/usr/bin/perl

use strict;
use warnings;

use Gtk3 -init;
use threads;

use AnyEvent::I3 qw(:all);

my $i3 = i3();
 
$i3->connect->recv or die "Error connecting";
my $workspaces = $i3->message(TYPE_GET_WORKSPACES)->recv;

my @wsp = map {$_->{'name'}} @$workspaces;
print join (", ", @wsp), "\n";

my $cwsp = (grep { $_->{'focused'} } @$workspaces)[0]->{'name'};
print "##: ", $cwsp, "\n";

#my ($cwsp, @wsp) = (shift @ARGV, @ARGV);

my $p = Gtk3::CssProvider->new;

$p->load_from_data ("
GtkWindow
{
    background-color: black;
}

GtkLabel 
{
    font: Monospace 40; 
    color: white;
}

GtkLabel#current
{
    color: #00f2ff;
}

");

my $d = Gtk3::Gdk::Display::get_default ();
my $s = $d->get_default_screen;

Gtk3::StyleContext::add_provider_for_screen ( $s, $p, Gtk3::STYLE_PROVIDER_PRIORITY_USER);

my $window = Gtk3::Window->new('toplevel');
my $box = Gtk3::Box->new('horizontal', 2);;
$window->add ($box);

for my $el (@wsp)
{
    my $l = Gtk3::Label->new ( $el );
    if ( $el == $cwsp )
    {
        $l->set_name ( "current" );
    }
    $box->pack_start ($l, 1, 1, 1);
}

$window->signal_connect ('destroy' => sub { Gtk3->main_quit() });
$window->show_all;

my $thr = threads->create(
sub { 
    select(undef, undef, undef, 0.25);
    $window->close()
});

Gtk3::main;
