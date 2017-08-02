#!/usr/bin/bash

TMP_FILE="/tmp/mon-setup.tmp"

MONITOR_0='HDMI-0'
MONITOR_1='DVI-0'

SELECT_TEXT=()
COMMANDS=()

SELECT_TEXT+=("Volume Control")
COMMANDS+=("pavucontrol")

SELECT_TEXT+=("Turn off screensaver")
COMMANDS+=("${HOME}/scripts/turn-off-screensaver.sh")

SELECT_TEXT+=("Dual Head")
COMMANDS+=("xrandr --output ${MONITOR_0} --left-of ${MONITOR_1}")

SELECT_TEXT+=("Clone")
COMMANDS+=("xrandr --output ${MONITOR_1} --same-as ${MONITOR_0}")

ITEMS=()
for i in "${!SELECT_TEXT[@]}"
do
    ITEMS+=("$i")
    ITEMS+=("${SELECT_TEXT[$i]}")
done

Xdialog\
    --wrap\
    --title "Monitor Setup Tool"\
    --wmclass "Monitor Setup Tool"\
    --no-tags\
    --menubox "" 200x200 0\
    "${ITEMS[@]}"\
    2> "${TMP_FILE}"

case $? in
    0)
        CMD_NR=$(cat "${TMP_FILE}") && ${COMMANDS[${CMD_NR}]};;
    1)
        exit;;
esac

trap "rm -f ${TMP_FILE}" EXIT
