#!/usr/bin/bash

WLAN='wlp3s0b1'

sudo ip addr add 192.168.2.1/24 broadcast 192.168.2.255 dev $WLAN
sudo ip link set ${WLAN} up

PIDS=""

sudo /usr/bin/hostapd /home/master/conf/hostapd.conf &
PIDS+="$! "

sudo dhcpd -4 -f -cf /home/master/conf/dhcpcd.conf $WLAN &
PIDS+="$! "

sudo /usr/bin/sshd -D -f /home/master/conf/ssh_config &
PIDS+="$! "

echo "$PIDS" > /tmp/pussynet.pids
