# Login-shell environment for systemd user services and remote sessions.
export PATH="$HOME/.local/bin:$HOME/.local/share/fnm:$PATH"

# PI WEB services use a non-interactive login shell, so Node must be
# initialized here rather than only in ~/.zshrc.
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --shell zsh)"
fi
