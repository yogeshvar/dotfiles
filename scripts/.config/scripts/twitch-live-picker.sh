#!/bin/bash
# Checks which of your favorite Twitch channels (~/.config/scripts/twitch-channels.txt)
# are currently live, using yt-dlp (no Twitch API app/credentials needed),
# shows a picker of just the live ones, and plays your choice in mpv.

CHANNELS_FILE="$HOME/.config/scripts/twitch-channels.txt"

if [ ! -s "$CHANNELS_FILE" ]; then
  echo "No channels in $CHANNELS_FILE yet — add some Twitch usernames first."
  read -r -p "Press enter to close..."
  exit 0
fi

check_channel() {
  channel="$1"
  title=$(yt-dlp --simulate --print "%(title)s" "https://twitch.tv/$channel" 2>/dev/null)
  if [ -n "$title" ]; then
    printf '%s — %s\n' "$channel" "$title"
  fi
}
export -f check_channel

echo "Checking who's live..."
live=$(grep -vE '^\s*(#|$)' "$CHANNELS_FILE" | xargs -P 8 -I{} bash -c 'check_channel "$@"' _ {})

if [ -z "$live" ]; then
  echo "None of your favorite channels are live right now."
  read -r -p "Press enter to close..."
  exit 0
fi

chosen=$(echo "$live" | fzf --prompt="Live now > ")
[ -z "$chosen" ] && exit 0

channel=$(echo "$chosen" | awk -F' — ' '{print $1}')
mpv "https://twitch.tv/$channel" &
