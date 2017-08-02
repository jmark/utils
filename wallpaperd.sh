#!/bin/sh

MIN_SECS=60
MAX_SECS=600

WALLPAPER_DIR="$HOME/.local/share/wallpapers"

while true
do
    feh --bg-fill "$(find "$WALLPAPER_DIR" -type f | shuf -n1)"
    sleep $(shuf -i "${MIN_SECS}-${MAX_SECS}" -n 1)
done
