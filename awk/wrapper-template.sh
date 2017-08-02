#!/usr/bin/env dash

# =========================================================================== #
## SELL WRAPPER for the awk tool

set -eu

is_positive_int()
{
    expr $1 : '^[0-9]\+$' > /dev/null
}

die()
{
    echo "$1" > /dev/stderr
    exit 1
}

usage()
{
    echo "usage: $0" 
    echo ""
    echo "  -v | --verbose              toggle verbose output"
    echo "  -w | --window=<uint>        set window width (must be positive integer)"
    echo "  -h | --help | --usage       print this usage message"
    echo ""
}

i=0
while [ $# -ne 0 ]
do
    i=$((i+1))

    case "$1" in

        --)     
            shift
            break 
            ;;

        -h|--help|--usage)
            usage && exit 0
            ;;

        -v|--verbose)
            VERBOSE=true
            shift
            ;;

        -w)
            window=$2
            is_positive_int $window || die "expected dpositive integer: '$1 $2' at position $i"
            shift 2
            ;;

        --window=[[:graph:]]*)
            window=${1#'--window='}
            is_positive_int $window || die "expected positive integer: '$1' at position $i"
            shift
            ;;

        *)
            die "invalid option: '$1' at position $i"
            ;;
    esac
done

VERBOSE=${VERBOSE:-false}
window=${window:-1}

exec awk -v verbose="$VERBOSE" -v wiwi="$window" '
BEGIN {
    print "verbose  ", verbose
    print "window   ", wiwi
}
'
