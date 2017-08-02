#!/usr/bin/perl -w

use v5.20;
use Net::SMTPS;
use File::Slurp;

my $server = 'send.one.com';
my $port   = 465;

my $mail = '';
{local $/ = undef;$mail = <>;}

exit 1 unless $mail;

my $smtp = Net::SMTPS->new($server, Port => $port, doSSL => 'ssl');
$smtp->auth('mail@jmark.de','DPac{fV[RmgIrruIdktCH_DI');



#write_file('/foo/out',join '',$mail);
