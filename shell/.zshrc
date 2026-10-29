unalias -m '*'
autoload -Uz compinit
# Reuse a dump for 24 hours. Check its age without a subprocess.
() {
  setopt localoptions extendedglob
  local dump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -r $dump && -n $dump(#qN.mh-24) ]]; then
    compinit -C -d "$dump"
  else
    # Remove an expired dump so compinit rebuilds even if the file count matches.
    zmodload -F zsh/files b:zf_rm
    zf_rm -f -- "$dump"
    compinit -d "$dump"
  fi
}

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh --log-level quiet)"
fi

if (( $+commands[fzf] )); then
  if (( $+commands[bat] )); then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :500 -- {}'"
  elif (( $+commands[batcat] )); then
    export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range :500 -- {}'"
  fi
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  elif (( $+commands[fdfind] )); then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'
  fi
  [[ -n ${FZF_DEFAULT_COMMAND:-} ]] && export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # Bindings need ZLE, which is absent in an interactive shell without a TTY.
  if [[ -o zle && -t 0 && -t 1 ]]; then
    # Old distro packages lack --zsh. Use their packaged scripts instead.
    if _fzf_init=$(fzf --zsh 2>/dev/null); then
      eval "$_fzf_init"
    else
      for _fzf_dir in /usr/share/doc/fzf/examples /usr/share/fzf/shell /usr/share/fzf \
          /opt/homebrew/opt/fzf/shell /usr/local/opt/fzf/shell; do
        if [[ -r "$_fzf_dir/key-bindings.zsh" ]]; then
          source "$_fzf_dir/key-bindings.zsh"
          [[ -r "$_fzf_dir/completion.zsh" ]] && source "$_fzf_dir/completion.zsh"
          break
        fi
      done
    fi
    unset _fzf_init _fzf_dir
  fi
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

alias lt="ls -lt"
alias lta="ls -la"
alias ltr="ls -ltR"
