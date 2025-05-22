#!/bin/bash

echo "Restarting Yabai..."
target_space=$1
existing_spaces=$(yabai -m query --spaces | jq '.[] | .index')

if echo "$existing_spaces" | grep -q "^$target_space$"; then
  yabai -m space --focus "$target_space"
else
  yabai -m space --create
  yabai -m space --focus last 
fi

osascript -e 'tell application "Übersicht" to refresh widget id "simple-bar-index-jsx"'