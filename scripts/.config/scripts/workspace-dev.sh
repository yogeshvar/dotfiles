#!/bin/bash
~/.config/scripts/ensure-space.sh 5 --focus
kitty -e tmux new-session -A -s dev &
pgrep -x "Cursor" >/dev/null || open -a "Cursor"
