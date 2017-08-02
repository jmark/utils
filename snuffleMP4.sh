#!/bin/sh

# snuffleMP4.sh: Snuff (mp4|mpeg|whatever) files from network link and leech it to disk.

sink="${1:?No save file path given!}"
link=$(ip route ls | grep -m1 default | awk '{print $5}')

tshark -Q -n -l -f tcp -Y http.request.method==GET -T fields -e http.request.full_uri -i $link \
    | grep -Pm1 'http://.+.(mp4|mpeg|mp3|avi)' \
    | xargs -I@ wget @ -O "$sink"
