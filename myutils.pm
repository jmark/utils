sub slurp {
    my ($path) = @_;
    my $fh;
    open $fh, '<', $path 
        or die "cannot read \"$path\": $!";
    my @data = <$fh>;
    close $fh;
    join '', @data;
}

sub spit {
    my ($data,$path) = @_;
    my $fh;
    open $fh, '>', $path 
        or die "cannot write to \"$path\": $!";
    print $fh $data;
    close $fh;
    1;
}

sub source {
    my ($path) = @_;
    my $src = slurp $path;
    eval $src;
}

1;
