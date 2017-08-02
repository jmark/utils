#!/usr/bin/awk -f

BEGIN {
    VARNAME = "fieldA"
}

NR == 1 && /^#/ {
    for(i = 2; i <= NF; ++i) {
        F[$i] = i-1
    }
    next
}

/^($|#)/ {
    next
}

// {
    print $F["fieldA"] - $F["fieldC"]
}
