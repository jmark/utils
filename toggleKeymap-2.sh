#!/bin/bash

CURRENT=`xkb-switch`;

if [ ${CURRENT} == 'us' ];then
    setxkbmap de;
else
    setxkbmap us;
fi
