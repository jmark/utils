#!/usr/bin/bash

echo "$*" >> /tmp/args.txt
echo >> /tmp/args.txt

FILE=$(echo "$1" | sed 's/\?.*$//' | awk -F/ '{print $NF}')

# wget "$1" \
#     --output-file="/tmp/wget.log" \
#     --user-agent="$2" \
#     --output-document="${HOME}/downloads/$FILE"

uget-gtk "$1"
