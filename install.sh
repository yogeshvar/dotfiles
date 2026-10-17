#!/usr/bin/env bash
# Rebuild this Mac's setup: Homebrew, packages, dotfiles, toolchains.
set -euo pipefail
cd "$(dirname "$0")"

xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "Finish the CLT install, then re-run."; exit 1; }
command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew bundle --file Brewfile

# stow packages (each top-level dir mirrors $HOME)
for pkg in zsh git tmux skhd yabairc yabai sketchybar kitty nvim btop fastfetch gh mpv scripts qutebrowser-profile; do
  stow -R --target="$HOME" "$pkg" || echo "stow $pkg failed (existing file in the way?)"
done

command -v rustup >/dev/null || curl https://sh.rustup.rs -sSf | sh -s -- -y
export NVM_DIR="$HOME/.nvm"; . "$(brew --prefix nvm)/nvm.sh"; nvm install --lts
echo "Next: restore ~/.ssh, ~/.aws, ~/.zshrc.local, run 'gh auth login', build yabai fork (see README)."
