# Keep this file silent: Zsh reads it for agent commands as well as terminals.
typeset -U path
export FNM_DIR="${FNM_DIR:-$HOME/.local/share/fnm}"
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$FNM_DIR/aliases/default/bin"
  /opt/homebrew/bin /opt/homebrew/sbin
  /usr/local/bin /usr/local/sbin
  $path
)
export PATH
