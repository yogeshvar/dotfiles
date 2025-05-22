#!/bin/bash

url="$1"
stream_url=$(yt-dlp -g "$url" 2>/dev/null)

if [[ -n "$stream_url" ]]; then
  open -a mpv "$stream_url"
else
  osascript -e 'display notification "Failed to resolve stream URL." with title "mpv"'
fi
