!/usr/bin/bash

STATE=`xrandr`;

#echo ${STATE} | grep DVI-0 | awk '{split($0,first," ");split(first[3],sec,"+")}
#END{print sec[2]}'

#xrandr --output DVI-0 --right-of HDMI-0

urxvt
