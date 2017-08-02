#!/usr/bin/env bash

STAMP=$(date +%Y-%m-%d-%H-%M-%S-%s)

mkdir -p ~/tmp/screenshots
import -window root png:$HOME/tmp/screenshots/$STAMP.png
