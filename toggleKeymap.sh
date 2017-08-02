#!/bin/bash

if [ $(xkb-switch) == 'us' ]
then
    setxkbmap de;
    notify-send "DE"
    echo -n de > '/tmp/keymap.txt'
else
    setxkbmap us;
    notify-send "US"
    echo -n en > '/tmp/keymap.txt'
fi

#~/scripts/status.sh
