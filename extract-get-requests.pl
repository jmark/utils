use v5.20;

$| = 1;

while (<>)
{
    my ($ip,$get,$url,$prt) = split / /;
    $prt = lc ((split/\//,$prt)[0]);
    my ($src,$dest) = split /-/,$ip;
    my @dest = map {$_+0} split /\./,$dest;

    say "$prt://$dest[0].$dest[1].$dest[2].$dest[3]:$dest[4]$url";
}
