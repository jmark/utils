#!/bin/sh
wget http://192.168.2.1/cgi-bin/disconnect.exe > /dev/null 2> /dev/null
sleep 5
wget http://192.168.2.1/cgi-bin/connect.exe > /dev/null 2> /dev/null
sleep 10
rm connect.exe disconnect.exe
echo "Reconnect durchgeführt."


