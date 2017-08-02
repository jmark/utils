#!/usr/bin/bash

if cd $1 2> /dev/null;then
    cd 'latex';
    urxvtc & &> /dev/null;
    vim -p Makefile main.tex sections/*.tex;
else
    echo "[ERROR] $1 not found"
fi
