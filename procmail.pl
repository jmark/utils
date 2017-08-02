#!/usr/bin/env myperl5.22

binmode STDOUT, ":encoding(UTF-8)";
autoflush STDOUT, 1;

use v5.20;
use experimental qw/signatures postderef lexical_subs/;

use Net::POP3;
use IO::Handle;
use Email::Simple;
use Perl6::Junction qw(any);

use File::Copy qw/move/;
use File::Path qw/make_path/;
use File::Temp qw/tempfile/;
use File::Spec::Functions qw/canonpath/;
use File::Slurp qw/read_file write_file/;

# ============================================================================ #

my $MAILDIR = "$ENV{HOME}/data/mail";
my $INBOX   = "$MAILDIR/inbox/";

gmail();
astro();
smail();
personal();

lists2();

#gmx();
#one_com();
#jm_one_com();

# ============================================================================ #

sub lists2 {
    procmails({
        pop  => 'pop.gmail.com',
        usr  => 'jmarkert.ml@gmail.com',
        pass => '[3RhBx|BtNxgGiesbgR5zugG',
        mail => 'jmarkert.ml@gmail.com',
        act  => sub($M)
        {
            my sub rule($address,$dest) {
                any (map {$M->header($_)} qw/ To Cc From Sender Delivered-To Reply-To /)
                ==
                qr/$address/i && deliver($M,"$MAILDIR/lists/$dest") && goto FIN;
            };

            rule qw/ niederrhein-pm@pm.org      perl-niederrhein.pm /;
            rule qw/ python-users@uni-koeln.de  python-users /;

            deliver($M, $INBOX);

            FIN: 1;
        },
    });
}


sub lists {
    procmails({
        pop  => 'pop.gmail.com',
        usr  => 'jmarkert.ml@gmail.com',
        pass => '[3RhBx|BtNxgGiesbgR5zugG',
        mail => 'jmarkert.ml@gmail.com',
        act  => sub($M) {
            my $rule = sub($test,$regex,$dest) {
                $test == qr/$regex/i && deliver($M,"$MAILDIR/lists/$dest") && goto FIN;
            };

            my $rules = sub($test,$regex,$dest,@lists) {
                $test == qr/@{[$regex->($_)]}/i
                    && deliver($M,"$MAILDIR/lists/".$dest->($_)) && goto FIN for (@lists);
            };

            my $origin  = any(
                $M->header('To'),$M->header('Cc'),$M->header('From'),
                $M->header('Sender'),$M->header('Delivered-To'),$M->header('Reply-To')
            );

            # --------------------------------------------------------------- #
            # FreeBSD

            $rules->($origin,sub{"$_[0]\@freebsd.org"},sub{"freebsd-$_[0]"},
                qw (lists questions announce chat stable hackers desktop perl python));

            $rules->($origin,sub{"freebsd-$_[0]\@freebsd.org"},sub{"freebsd-$_[0]"},
                qw (lists questions announce chat stable hackers desktop perl python));

            $rule->($origin,'de-bsd-questions@de.freebsd.org','freebsd_de-questions');

            # --------------------------------------------------------------- #
            # ArchLinux

            $rules->($origin,sub{"arch-$_[0]\@archlinux.org"},sub{"archlinux-$_[0]"},
                qw (announce events general commits projects security));

            $rules->($origin,sub{"aur-$_[0]\@archlinux.org"},sub{"archlinux_aur-$_[0]"},
                qw (requests general dev));

            $rule->($origin,'pacman-dev@archlinux.org','archlinux_pacman-dev');

            # --------------------------------------------------------------- #
            # perl5/perl6

            $rule->($origin,'perl6-language@perl.org','perl6-dev');
            $rule->($origin,'beginners@perl.org','perl-beginners');
            $rule->($origin,'bugs-bitbucket@rt.perl.org','perl6-dev');
            $rule->($origin,'perl5-changes@perl.org','perl5-changes');
            $rule->($origin,'niederrhein-pm@pm.org','perl-niederrhein.pm');

            # --------------------------------------------------------------- #
            # Suckless.org/Plan9

            $rule->($origin,'9fans@9fans.net','9fans');
            $rule->($origin,'9front@9front.org','9front');
            $rule->($origin,'cat-v-owner@pp.inri.net','cat-v');
            $rule->($origin,'cat-v@cat-v.org','cat-v');
            $rule->($origin,'dev@suckless.org','suckless-dev');
            $rule->($origin,'wiki@suckless.org','suckless-wiki');
            $rule->($origin,'hackers@suckless.org','suckless-hackers');
            $rule->($origin,'9front-issues@9front.org','9front-issues');
            $rule->($origin,'9front-commits@9front.org','9front-commit');
            $rule->($origin,'9front-bugs@9front.org','9front-bugs');

            # better perl code
            # rule qw/  9front-bugs@9front.org  9front-bugs /;

            # good tcl code
            # rule    9front-bugs@9front.org      9front-bugs
            # rule    hackers@suckless.org        suckless-hackers
            # rule    9front-issues@9front.org    9front-issues

            # --------------------------------------------------------------- #
            # Pythonics

            $rule->($origin,'python-de@python.org','python-de');
            $rule->($origin,'python-dev@python.org','python-dev');
            $rule->($origin,'python-de@mail.python.org','python-de');
            $rule->($origin,'python-users@uni-koeln.de','python-users');
            $rule->($origin,'nuitka-dev@freelists.org','python-nuitka');

            # --------------------------------------------------------------- #
            # Haskell

            $rule->($origin,'haskell@haskell.org','haskell');
            $rule->($origin,'haskell-cafe@haskell.org','haskell-cafe');
            $rule->($origin,'beginners@haskell.org','haskell-beginners');
            $rule->($origin,'haskell-cafe@googlegroups.com','haskell-cafe');

            # --------------------------------------------------------------- #
            # SysLinux

            $rule->($origin,'syslinux@zytor.com','syslinux');

            # --------------------------------------------------------------- #
            # InfoSec

            $rule->($origin,'risks-resend@csl.sri.com','risks');
            $rule->($origin,'dc-stuff@dc-stuff.org','dc-stuff');
            $rule->($origin,'isn@lists.infosecnews.org','infosecnews');
            $rule->($origin,'email@blackhat.messages4.com','blackhat');

            # --------------------------------------------------------------- #
            # DLR

            $rule->($origin,'contact-dlr@dlr.de','DLR');

            # --------------------------------------------------------------- #
            # tcl/tk

            $rule->($origin,'tcl-core@lists.sourceforge.net','tcl-core');

            # --------------------------------------------------------------- #
            # Xorg/Radeon/Mesa3D/Freedesktop

            $rule->($origin,'xorg@lists.x.org','xorg');
            $rule->($origin,'xorg@freedesktop.org','xorg');
            $rule->($origin,'xorg@lists.freedesktop.org','xorg');
            $rule->($origin,'piglit@lists.freedesktop.org','piglit');
            $rule->($origin,'mesa-dev@lists.freedesktop.org','mesa-dev');
            $rule->($origin,'mesa-dev@freedesktop.org','mesa-dev');
            $rule->($origin,'dri-devel@lists.freedesktop.org','dri-dev');
            $rule->($origin,'xorg-driver-ati@lists.x.org','xorg-driver-ati');
            $rule->($origin,'mesa-users@lists.freedesktop.org','mesa-users');
            $rule->($origin,'xorg-driver-ati-bounces@lists.x.org','xorg-driver-ati');

            # --------------------------------------------------------------- #
            # i3wm

            $rule->($origin,'i3-discuss@i3.zekjur.net','i3wm');
            $rule->($origin,'i3-announce@i3.zekjur.net','i3wm');

            # --------------------------------------------------------------- #
            # arxive

            $rule->($origin,'^cs@arXiv.org','arxive-cs');
            $rule->($origin,'^stat@arXiv.org','arxive-stat');
            $rule->($origin,'^math@arXiv.org','arxive-math');
            $rule->($origin,'^physics@arXiv.org','arxive-physics');

            # --------------------------------------------------------------- #
            # tor

            $rule->($origin,'tor-talk@lists.torproject.org','tor-talk');
            $rule->($origin,'tor-relays@lists.torproject.org','tor-relays');
            $rule->($origin,'tor-announce@lists.torproject.org','tor-announce');

            # --------------------------------------------------------------- #
            # gnuplot

            $rule->($origin,'gnuplot-info@lists.sourceforge.net','gnuplot');

            # --------------------------------------------------------------- #
            # dante-ev

            $rule->($origin,'dante-ev-bounces@dante.de','dante-ev');

            # --------------------------------------------------------------- #
            # Freifunk

            $rule->($origin,'freifunk-bonn@lists.bonn.freifunk.net','freifunk');
            $rule->($origin,'freifunk-bonn@lists.kbu.freifunk.net','freifunk');

            # --------------------------------------------------------------- #
            # Last resort

            deliver($M,$INBOX);

            # --------------------------------------------------------------- #
            # Successfully delivered!

            FIN: 1;
        },
    });
}

sub one_com {
    procmails({
        pop  => 'pop.one.com',
        usr  => 'mail@jmark.de',
        pass => 'DPac{fV[RmgIrruIdktCH_DI',
        mail => 'mail@jmark.de',
        act  => sub($M){deliver($M,$INBOX)},
    });
}

sub jm_one_com {
    procmails({
        pop  => 'pop.one.com',
        usr  => 'johannes.markert@jmark.de',
        pass => 'pxVi_8CON#hKFQhVPPIw#CeC',
        mail => 'johannes.markert@jmark.de',
        act  => sub($M){deliver($M,$INBOX)},
    });
}

sub gmail {
    procmails({
        pop  => 'pop.gmail.com',
        usr  => 'johannes.markert@gmail.com',
        pass => 'vYVlWw1pQPsF0p1+co3kU+fNCMTLW70BIY1q0cLMhA0=',
        mail => 'johannes.markert@gmail.com',
        act  => sub($M)
        {
            my sub rule($address,$dest) {
                any (map {$M->header($_)} qw/ To Cc From Sender Delivered-To Reply-To /)
                ==
                qr/$address/i && deliver($M,$dest) && goto FIN;
            };

            rule qw! de-bsd-questions@de.freebsd.org lists/de-bsd !;

            deliver($M, $INBOX);

            FIN: 1;
        }
    });
}

sub gmx {
    procmails({
        pop  => 'pop.gmx.de',
        usr  => 'jmark-ml@gmx.de',
        pass => 'r7UpVmr47Az-iJjhx9[NtKsa',
        mail => 'jmark-ml@gmx.de',
        act  => sub($M){deliver($M,$INBOX)},
    });
}

sub smail {
    procmails({
        pop  => 'pop.uni-koeln.de',
        usr  => 'jmarker1',
        #pass => 'i_0N#Po5zlVkUZ',
        pass => 'bJgirl1993',
        mail => 'jmarker1@smail.uni-koeln.de',
        act  => sub($M)
        {
            my sub rule($address,$dest) {
                any (map {$M->header($_)} qw/ To Cc From Sender Delivered-To Reply-To /)
                ==
                qr/$address/i && deliver($M,"$MAILDIR/$dest") && goto FIN;
            };

            rule qw! thp-members@uni-koeln.de       lists/cmt !;
            rule qw! cmt-groupsem@uni-koeln.de      lists/cmt !;
            rule qw! quantum-matter@uni-koeln.de    lists/cmt !;
            rule qw! cmt-seminar@uni-koeln.de       lists/cmt !;

            rule qw! swgroup@mail.ph1.uni-koeln.de  lists/swgroup !;
            rule qw! flash-users@flash.uchicago.edu lists/flash !;

            deliver($M, $INBOX);

            FIN: 1;
        }
    });
}

sub personal {
    procmails({
        pop  => 'pop.uni-koeln.de',
        usr  => 'jmarker2',
        #pass => 'i_0N#Po5zlVkUZ',
        pass => 'bJgirl1993',
        mail => 'jmarker2@uni-koeln.de',
        act  => sub($M)
        {
            my sub rule($address,$dest) {
                any (map {$M->header($_)} qw/ To Cc From Sender Delivered-To Reply-To /)
                ==
                qr/$address/i && deliver($M,"$MAILDIR/$dest") && goto FIN;
            };

            rule qw! cheops-users@uni-koeln.de  Studium/cheops !;
            rule qw! hpc-events@uni-koeln.de	lists/hpc-events !;

            deliver($M, $INBOX);

            FIN: 1;
        }


    });
}

sub astro {
    procmails({
        pop  => 'mail.ph1.uni-koeln.de',
        usr  => 'markert',
        #pass => 'i_0N#Po5zlVkUZ',
        pass => 'bJgirl1993',
        mail => 'markert@ph1.uni-koeln.de',
        act  => sub($M)
        {
            my sub rule($address,$dest) {
                any (map {$M->header($_)} qw/ To Cc From Sender Delivered-To Reply-To /)
                ==
                qr/$address/i && deliver($M,"$MAILDIR/$dest") && goto FIN;
            };

            rule qw! hera@mail.ph1.uni-koeln.de lists/hera !;
            rule qw! hera@ph1.uni-koeln.de      lists/hera !;
            rule qw! silcc@girichidis.com       lists/silcc !;

            deliver($M, $INBOX);

            FIN: 1;
        }
    });
}

# ============================================================================ #

sub procmails($args) {
    my $pop = Net::POP3->new($args->{pop}, SSL=>1, Debug => 0)
        || die "Cannot access to POP3 Server $args->{pop} : $!\n";
    defined ($pop->login($args->{usr}, $args->{pass}))
        || die "Invalid login or password: $!\n";

    say "[$args->{mail}]";
    while(my @msgIDs = keys %{$pop->list}) {
        for my $id (@msgIDs) {
            my @msg = @{($pop->get($id) || do {warn "Cannot read email $id: $!n";next;})};
            my $M = Email::Simple->new(join '',@msg);
            put($id,$M) && $args->{act}->($M) && $pop->delete($id);
        }
    }
    $pop->quit;
}

sub put($id,$M) {
    my ($fr,$to,$su) = ($M->header('From'),$M->header('To'),$M->header('Subject'));
    printf "[%3d] %-25.25s -> %-25.25s | %-30.30s\n",$id,$fr,$to,$su;
}

sub deliver($M,$dest) {
    do {die unless make_path($dest)} unless -e $dest;

    my ($fh, $fn) = tempfile( DIR => $dest );
    write_file($fh,$M->as_string);

    move($fn, canonpath("$dest/".(stat $fn)[1]))
        || die "Cannot rename tempfile: $!\n";
}
