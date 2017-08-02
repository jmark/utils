#!/usr/bin/bash

WLAN='wlp3s0b1'

sudo kill $(cat /tmp/pussynet.pids)
sudo ip link set $WLAN down
