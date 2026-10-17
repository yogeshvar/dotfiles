#!/bin/bash
#
# Raycast Script Command — launch the live VALORANT stream in mpv.
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Watch Valorant
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🎮
# @raycast.packageName Valorant
# @raycast.argument1 { "type": "dropdown", "placeholder": "Mode", "optional": true, "data": [ {"title":"Corner overlay","value":"-p"}, {"title":"Fullscreen","value":"-f"}, {"title":"Normal window","value":"-w"} ] }
# @raycast.argument2 { "type": "text", "placeholder": "channel (optional)", "optional": true }
#
# Documentation:
# @raycast.description Open the live VALORANT stream in mpv. Auto-finds the first live channel (gofns, then the regional broadcasts).
# @raycast.author yogeshvar

export PATH="/opt/homebrew/bin:$HOME/Work/Fun/dotfiles/bin:$PATH"

# Default to the always-on-top corner overlay if no mode is picked.
mode="${1:--p}"

# Launch detached so Raycast returns immediately and mpv keeps running.
nohup val "$mode" ${2:+"$2"} >/dev/null 2>&1 &
disown
