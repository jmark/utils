#!/usr/bin/bash -i

export HISTFILE=~/.gmrun_history
history -c
history -r

alias google="web google"

read -p "~~> " -e CMD
($CMD &)

set -o history
history -s "$CMD"
