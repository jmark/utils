
use strict;
use warnings;

use File::Slurp;
use Text::Table;

my $txt = read_file ('/home/master/2014-01-ct-linux.txt');
my @words = split /\s+/,$txt;
my %words = ();

for my $word (@words)
{
    $word = lc($word);
    if (split(//,$word) > 3)
    { 
        if ($words{$word})
        {
            $words{$word}++;
        }
        else
        {
            $words{$word} = 1;
        }
    }
}

my @wc = map {[$_,$words{$_}]} sort {$words{$b}<=>$words{$a}} 
         grep {$words{$_} > 4} keys %words;

my $tb = Text::Table->new("Word", "Count");

$tb->load(@wc);
print $tb;
