#!/bin/bash
~/.config/scripts/new-space.sh
kitty -e tmux new-session -A -s dev &
open -n -a "Cursor"
