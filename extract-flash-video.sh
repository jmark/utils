#!/usr/bin/env bash

INTERFACE='enp3s0'

tshark -i $INTERFACE -f tcp -Y http.request.method=="GET" -T fields -e http.request.full_uri \
    | grep --line-buffered -Pi "mp4|mpeg|flv"
