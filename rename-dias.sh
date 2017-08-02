#!/bin/bash

IFS='
';

PICS=(`find ~/Dias-Schneeberger -name "*.jpg" | sort -n`);

iter=1;
for i in "${PICS[@]}"
do
   #echo "${i} -> ~/Dias/dias-${iter}.jpg":
   NR=`printf "%03d" ${iter}`;
   cp -v ${i} ~/Dias/dias-${NR}.jpg;
   let iter++;
done
