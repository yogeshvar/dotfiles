# ~/.zshrc — lean, fast zsh config.
# Heavy plugins load in the background (zinit "turbo" mode) right after the
# first prompt paints, so startup stays snappy.

### Zinit plugin manager bootstrap
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}zdharma-continuum/zinit%F{220} (plugin manager)…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit annexes (required for some ice modifiers)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### Prompt: Pure — loaded eagerly so the prompt paints immediately
fpath+=("$(brew --prefix)/share/zsh/site-functions")
fpath+=~/.zsh/completions
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

### Completions (eager + fast). -C skips the once-a-day fpath security audit;
### drop the -C if you ever add completion dirs from untrusted sources.
autoload -Uz compinit && compinit -C

### Interactive plugins. Order matters: autosuggestions first,
### syntax-highlighting LAST (it must wrap all other ZLE widgets).
# fast-syntax-highlighting colors valid commands green and unknown ones red as
# you type, so typos are obvious before you press Enter.
zinit light redxtech/zsh-kitty
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# Autosuggestion color — a mid-grey that stays readable on light or dark themes.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

### PATH / tools
export PATH="$HOME/Work/Fun/dotfiles/bin:$PATH"   # personal scripts (sit-clone, …)
export PATH="$PATH:$HOME/.spicetify"

# Homebrew Ruby + its gem executables (newer than macOS system Ruby).
# Gems dir uses Ruby's API version (e.g. 4.0.0); update if you bump Ruby major/minor.
# NOTE: was originally added for colorls (now removed) — safe to delete this
# block if you don't use any other Homebrew-Ruby gem CLIs.
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"

# PostgreSQL (keg-only postgresql@16)
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
alias psql-start='brew services start postgresql@16'
alias psql-end='brew services stop postgresql@16'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# nvm — lazy-loaded: sourced on first use of nvm/node/npm/npx to keep startup fast.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx corepack pnpm yarn claude 2>/dev/null
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
# These all live in the nvm node bin, so touching any of them loads nvm first.
for _cmd in nvm node npm npx corepack pnpm yarn claude; do
  eval "${_cmd}() { _load_nvm; ${_cmd} \"\$@\"; }"
done
unset _cmd

### Listing aliases — plain colored ls (no icons). -G enables color on macOS.
alias l='ls -lahG'
alias la='ls -lAhG'
alias ll='ls -lhG'

### SIT project dev sessions (tmux layout: claude + web/api + nvim). See bin/sit-dev.
alias sit-medditour='sit-dev medditour-v2'
alias sit-arogyanow='sit-dev arogyanow'

export TERM=xterm-kitty

# Machine-local, NEVER-committed overrides (secrets, DB URLs, etc.).
# ~/.zshrc.local lives outside this (public) dotfiles repo on purpose.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
