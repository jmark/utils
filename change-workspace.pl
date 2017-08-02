#!/usr/bin/perl
use strict;
use warnings;
use AnyEvent::I3 qw(:all);
use EV;
use Data::Dumper;

my $i3 = i3();
 
$i3->connect->recv or die "Error connecting";
print "Connected to i3\n";
 
my $workspaces = $i3->message(TYPE_GET_WORKSPACES)->recv;
print "Currently, you use " . @{$workspaces} . " workspaces\n";

my %handler = (
    workspace => sub {
        my ($msg) = @_;

        if ( $msg->{'change'} eq 'focus')
        {
            my $wsp = i3->get_workspaces->recv;
            my @wsp = map {$_->{'name'}} @$wsp;

            #print join("\n",@wsp),"\n\n";
            system 'perl /home/hannezzz/scripts/wsp-viewer.pl 2> /dev/null '
            . $msg->{'current'}->{'name'} . ' '. join (" ", @wsp);
        }
    }
);

if ($i3->subscribe(\%handler)->recv->{success}) {
    print "Successfully subscribed\n";
}

EV::loop;
