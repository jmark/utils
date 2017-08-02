#!/bin/bash

CURRENT=`xkb-switch`;

if [ ${CURRENT} == 'us' ];then
    setxkbmap de;
    /opt/scripts/notify.pl 100 'DE';
else
    setxkbmap us;
    /opt/scripts/notify.pl 100 'US';
fi
