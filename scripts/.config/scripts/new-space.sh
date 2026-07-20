#!/bin/bash
# new-space.sh — always creates a brand new space and focuses it, regardless
# of how many already exist. Used by the workspace launchers, which should
# never land you back on a space you already have something running in.
yabai -m space --create
yabai -m space --focus last
