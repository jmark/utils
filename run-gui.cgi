#!/usr/bin/bash

echo "Content-type: text/text"
echo

export HOME=/home/master
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000

mpv /foo/pr0n/*
