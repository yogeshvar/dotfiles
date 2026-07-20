#!/bin/bash
~/.config/scripts/ensure-space.sh 1 --focus
pgrep -x "Safari" >/dev/null || open -a "Safari"
