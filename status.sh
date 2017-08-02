#!/usr/bin/bash

# =========================================================================== #
# Battery

PATH_BAT='/sys/class/power_supply/BAT1'
BAT='bat:'
if [ -e  $PATH_BAT ]
then
    BAT="$BAT $(printf '%0.1f' $(echo "$(cat $PATH_BAT/charge_now)/$(cat $PATH_BAT/charge_full)*100" | bc -l))%"
    # echo "$(date +%s) $(cat $PATH_BAT/status) $(cat $PATH_BAT/charge_now) $(cat $PATH_BAT/charge_full)" >> ~/bat1.csv
else
    BAT="$BAT --"
fi

# =========================================================================== #
# Disk

DISK="disk: $(df -h | grep root | awk '{print $3"/"$2}')"

# =========================================================================== #
# RAM

MEM="mem: $(free -m | grep 'Mem:' | awk '{print $3"M/"$2"M"}')"

# =========================================================================== #
# date
export LANG=de_DE.UTF-8
DATE=$(date +'%a, %d.%m.%Y | %H:%M')
KEYMAP=$(cat /tmp/keymap.txt)

# NET="net:"
# if ping -W1 -c1 8.8.8.8 &> /dev/null
# then
#     NET="$NET yes"
# else
#     NET="$NET no"
# fi

xsetroot -name "km: $KEYMAP | $MEM | $DISK | $BAT | $DATE"
