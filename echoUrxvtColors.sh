#!/bin/bash
# prg318
# Lukas Sabota - <LTsmooth42 _at_ gmail _dot_ com>
#
# Simple rxvt color print script
#
# Prints each rxvt color code in the color that its currently
# configured to. This can be of assistance while configuring
# rxvt colors by hand. You may want to use gcolor2 as well:
# - http://gcolor2.sourceforge.net/
#
# See the "COLOURS AND GRAPHICS" section of the urxvt/rxvt manual
# more details on configuring rxvt.
#

names=('black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' \
    'white' 'bright black' 'bright red' 'bright green' 'bright yellow' \
    'bright blue' 'bright magenta' 'bright cyan' 'bright white')

r=0
for i in `seq 0 1`
do
    for j in `seq 30 37`
    do
        echo -n -e '\e['$i';'$j'm'urxvt*color$r -
        echo " ${names[$r]}"
        r=`expr $r + 1`
    done
done
echo -e '\e[0m' # reset text color
