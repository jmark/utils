#!/usr/bin/bash

BROWSER="/usr/bin/env surf -nps"

ARGV="$*"
CMD="$1"
shift

case "$CMD" in
    google)
        PREFIX="https://www.google.de/search?q="
        $BROWSER "${PREFIX}${*}"
        ;;

    gimages)
        PREFIX="https://www.google.de/search?&q="
        SUFFIX="&gbv=1&um=1&ie=UTF-8&tbm=isch&source=og&sa=N&tab=wi"
        $BROWSER "${PREFIX}${*}${SUFFIX}"
        ;;

    gmaps)
        PREFIX="https://maps.google.de/maps?q="
        $BROWSER -S "${PREFIX}${*}"
        ;;

    github)
        PREFIX="https://github.com/search?utf8=%E2%9C%93&q="
        $BROWSER "${PREFIX}${*}"
        ;;

    dcc)
        PREFIX="http://www.dict.cc/?s="
        $BROWSER "${PREFIX}${*}"
        ;;

    clip)
        $BROWSER "$(xclip -o -selection clipboard)"
        ;;

    primary)
        $BROWSER "$(xclip -o -selection primary)"
        ;;

    pussy)
        $BROWSER -w pussy "${*}"
        ;;

    wen|wiki)
        PREFIX='https://en.wikipedia.org/w/index.php?search='
        $BROWSER "${PREFIX}${*}"
        ;;

    wde)
        PREFIX='https://de.wikipedia.org/w/index.php?search='
        $BROWSER "${PREFIX}${*}"
        ;;

    duck)
        PREFIX='https://duckduckgo.com/html?q='
        $BROWSER "${PREFIX}${*}"
        ;;

    mensa)
        URL='http://www.kstw.de/index.php?option=com_speiseplan&zeit=heute&lang=de'
        $BROWSER -S $URL
        ;;

    *)
        $BROWSER "$ARGV"
esac
