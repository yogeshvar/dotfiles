#!/bin/bash
# ensure-space.sh N [--focus] — creates spaces until space N exists.
# With --focus, also focuses it (only safe when you're not about to move
# the currently-focused window there afterward — switching focus first
# means "the focused window" becomes whatever's on the new space, so
# window-move callers must create first, move the window, then focus).
target="$1"
mode="$2"
if [ -z "$target" ]; then
  echo "usage: ensure-space.sh <space-number> [--focus]" >&2
  exit 1
fi

count=$(yabai -m query --spaces | jq 'length')
if [ "$count" -lt "$target" ]; then
  for _ in $(seq $((target - count))); do
    yabai -m space --create
  done
fi

if [ "$mode" = "--focus" ]; then
  yabai -m space --focus "$target"
fi
