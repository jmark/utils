use v5.20;
use File::Slurp;

my $file = "$ENV{HOME}/.mail/inbox";
my @mbox = read_file($file);

{local $/ = "\r\n"; chomp (@mbox)};

my $i = -1;
my @mail = ();
for my $line (@mbox)
{
    if($line =~ /^From /)
    {
        $i++;
        $mail[$i] = {};
    }

    $mail[$i]->{subject} = "$line" if $line =~ /^Subject: conf/;

    if($line =~ /^From: /)
    {
        my $from = (split / /,$line)[1];
        $mail[$i]->{to} = "$from";
    }
}

die 'Missing argument: "sender"' unless $ARGV[0];
my $fr = $ARGV[0];

for my $M (@mail)
{
    my $to  = $M->{'to'};
    my $sb = $M->{'subject'};

    my $cmd = "printf '%s\\n\\n' \"$sb\" | mail -a $fr $to";
    say $cmd;

    `$cmd`;
}
