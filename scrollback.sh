#!/usr/bin/env bash

TMPFILE=/run/user/$UID/tmux-scrollback-buffer_iwi9i2349jno5349k.txt
#tmux capture-pane -e -p -S -5000 > $TMPFILE && less -r +G $TMPFILE
tmux capture-pane -p -S -5000 > $TMPFILE && less -r +G $TMPFILE
