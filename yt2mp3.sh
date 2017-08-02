#!/usr/bin/bash

youtube-dl "$1" -o- | ffmpeg -i - "$(youtube-dl -e "$1" | sed 's/\//-/g')".mp3
