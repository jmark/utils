#!/bin/bash

if [ ! `pgrep dunst` ];then
    dunst -fn "Inconsolata 50" &> /dev/null &
fi
   
start=`date +%s`;
echo 'start:' `date --date=@${start} +%H:%M:%S`;

# function finish {
#     diff=$((`date +%s`-$start));
#     echo "${start} ${diff}" >> ~/worktime;
#     exit;
# }
# trap finish EXIT

stop=$((90*60))

while true;
do
    diff=$((`date +%s`-$start));
    
    count=`date --date="@$((diff-60*60))" +%H:%M:%S`;
    echo -ne "elaps: ${count}\033[0K\r";
    sleep 1;

    if [[ "$diff" -ge "$stop" ]];then
        notify-send "Time for a break!";
    fi 
done;
