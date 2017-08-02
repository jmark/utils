#!/bin/dash

#echo "$@" > ~/tmp/xdg-open.params.txt'

URI="$1"

if echo "$URI" | grep -q '^[[:alnum:]]\+://'
then
    SCHEME=$(echo "$URI" | awk -F:// '{print $1}')
    FILE=$(echo "$URI" | awk -F:// '{print $2}')
else
    FILE="$URI"
fi

FILE_EXT=$(echo "$FILE" | perl -F'\.' -e 'print lc($F[-1])')

if echo "$URI" | grep -qi '/home/jmark/docs/'
then
    FILE_EXT='pdf'
fi

case "$FILE_EXT" in
        pdf)    evince "$FILE" ;;
        djvu)   evince "$FILE" ;;
        html)   chromium "$FILE" ;;
        txt|tdl)    geany "$FILE" ;;
        *)      /usr/bin/xdg-open "$FILE" ;;
esac
