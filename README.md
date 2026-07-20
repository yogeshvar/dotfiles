# dotfiles

Personal macOS config: yabai, skhd, sketchybar, borders, mpv, kitty, tmux, nvim, and workspace launcher scripts.

## yabai on macOS 27 (Golden Gate beta) — read this before reinstalling

The stock `asmvik/formulae/yabai` Homebrew formula (both the stable release and `--HEAD`) does **not** support space creation/destruction on this macOS build (`26A5378n`) — `yabai -m space --create` silently returns success and does nothing. Apple reorganized internal Dock.app functions in this beta, breaking yabai's scripting-addition hooks for `add_space` specifically (everything else — focus, swap, resize, layout — works fine through the stock formula).

**Fix**: build from [AhsanFazal/yabai](https://github.com/AhsanFazal/yabai), a community fork tracking Golden Gate beta compatibility (see [asmvik/yabai#2802](https://github.com/asmvik/yabai/issues/2802)).

```sh
# one-time: create a stable code-signing identity so Accessibility
# permission survives rebuilds (Keychain Access -> Certificate Assistant
# -> Create a Certificate -> Name: yabai-cert, Identity Type: Self Signed
# Root, Certificate Type: Code Signing)

git clone https://github.com/AhsanFazal/yabai /tmp/yabai-fork
cd /tmp/yabai-fork
make
make install-local   # prompts for sudo password a few times, handles
                      # codesigning, sudoers, SA loading, service start
```

After the first install with a new signature, macOS will ask for Accessibility permission once (System Settings → Privacy & Security → Accessibility) — grant it, and since the binary is now signed with `yabai-cert` (a stable identity) instead of an ad-hoc signature, it persists across future rebuilds/updates instead of resetting every time.

If a future macOS beta build changes things again: check that repo/issue for updated offsets before assuming something in this dotfiles setup is broken.

## Layout

Stow-style: each top-level folder mirrors `$HOME` (e.g. `skhd/.skhdrc` → `~/.skhdrc`, `scripts/.config/scripts/` → `~/.config/scripts/`). No symlinks currently — configs are copied, not linked; re-sync manually after editing either the live files or this repo.
