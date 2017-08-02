#!/usr/bin/env dash

set -eu

OFS="$IFS"
IFS='%%%'

DATFILE="$1"
shift

PARAMS=$(awk -F'\n' '
/^#_(FIN|END)_/ {
    exit
}

/^#_COLUMNS_/ {
    n = split(substr($0,12),TMP,",")
    for (i=1;i<=n;i++) {
        printf("COL_%s=%d;",TMP[i],i)
    }
    next
}

/^#/ {
    printf("%s;", substr($1,2))
    next
}
' "$DATFILE")

gnuplot -e "_DATFILE_='$DATFILE';$PARAMS" "$@"
