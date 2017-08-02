#!/bin/sh

i3status | while :
    do
        read line
        echo "`xkb-switch` | $line"
        sleep 1
    done
