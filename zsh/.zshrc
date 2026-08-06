# Powerlevel10k instant prompt. Keep near the top of this file.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode reminder
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  tldr
)

source "$ZSH/oh-my-zsh.sh"

# Modern file listing.
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons -L 2'

# User-installed commands and uv-managed Python tools.
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# fnm manages Node.js and switches versions when entering projects.
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# fzf keybindings and completion when available.
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
if command -v bat >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=numbers --line-range :500 {}'"
elif command -v batcat >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--preview 'batcat --color=always --style=numbers --line-range :500 {}'"
fi

# Smarter directory navigation.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Optional machine-specific settings, intentionally not tracked.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
