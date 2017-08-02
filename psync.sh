#!/bin/sh

# Sync mp3 files with my player plugged in via usb

set -eu

UUID=806B-13F6
MNT_DIR=/mnt/galaxy
SRC_DIR=~/mp3
SNK_DIR=${MNT_DIR}/media/podcast/

if ! mountpoint -q ${MNT_DIR}
then
    sudo mount /dev/disk/by-uuid/${UUID} ${MNT_DIR} -o uid=$(id -g) -o gid=$(id -g) -o flush
fi

mv -v ${SRC_DIR}/*.mp3 ${SNK_DIR}
sudo umount ${MNT_DIR}
