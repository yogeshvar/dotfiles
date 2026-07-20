#!/bin/bash
~/.config/scripts/ensure-space.sh 2 --focus
pgrep -x "Brave Browser" >/dev/null || open -a "Brave Browser"
