#!/bin/bash

PICS='/home/hannezzz/pic'

IFS=$'\n'
ARRAY=(`find $PICS -type f`)

RANGE=${#ARRAY[@]}

INDEX=$RANDOM
let INDEX%=$RANGE
let INDEX+=1

feh --bg-max ${ARRAY[$INDEX]}
