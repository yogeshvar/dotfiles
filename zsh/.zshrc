source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

## Kitty ZSH Plugin
zinit light redxtech/zsh-kitty
# it also works with turbo mode:
zinit ice wait lucid
zinit load redxtech/zsh-kitty

## Pure ZSH Theme — minimalist prompt (replaces powerlevel10k).
fpath+=("$(brew --prefix)/share/zsh/site-functions")
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure
export PATH=$PATH:/Users/mags/.spicetify

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Homebrew Ruby + its gem executables on PATH so `gem which colorls` and the
# colorls aliases resolve (system Ruby 2.6 is too old for colorls). The gems
# dir uses Ruby's API version (e.g. 4.0.0); update if you bump Ruby major/minor.
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"

source $(dirname $(gem which colorls))/tab_complete.sh

alias lc='colorls -lA --sd'
alias l='colorls -lA'
alias ll='colorls'

fpath+=~/.zsh/completions
autoload -Uz compinit && compinit

export TERM=xterm-kitty

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# PostgreSQL (keg-only postgresql@16): put server/client tools on PATH
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
# start / stop the local postgres server
alias psql-start='brew services start postgresql@16'
alias psql-end='brew services stop postgresql@16'

# Machine-local, NEVER-committed overrides (secrets, DB URLs, etc.).
# ~/.zshrc.local lives outside this (public) dotfiles repo on purpose.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
