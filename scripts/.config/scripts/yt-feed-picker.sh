#!/bin/bash
# Lists recent uploads from your favorite YouTube channels
# (~/.config/scripts/youtube-channels.txt) via yt-dlp — no API key, no
# algorithm, just what those channels actually posted — shows a picker,
# and plays your choice in mpv.

CHANNELS_FILE="$HOME/.config/scripts/youtube-channels.txt"

if [ ! -s "$CHANNELS_FILE" ]; then
  echo "No channels in $CHANNELS_FILE yet — add some YouTube channel URLs first."
  read -r -p "Press enter to close..."
  exit 0
fi

fetch_channel() {
  url="$1"
  yt-dlp --flat-playlist --playlist-end 8 --print "%(title)s	%(webpage_url)s" "${url%/}/videos" 2>/dev/null
}
export -f fetch_channel

echo "Fetching recent uploads..."
feed=$(grep -vE '^\s*(#|$)' "$CHANNELS_FILE" | xargs -P 8 -I{} bash -c 'fetch_channel "$@"' _ {})

if [ -z "$feed" ]; then
  echo "Couldn't fetch anything — check the channel URLs in $CHANNELS_FILE."
  read -r -p "Press enter to close..."
  exit 0
fi

chosen=$(echo "$feed" | fzf --prompt="Watch > " --delimiter=$'\t' --with-nth=1)
[ -z "$chosen" ] && exit 0

url=$(echo "$chosen" | awk -F'\t' '{print $2}')
mpv "$url" &
