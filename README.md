# Dotfiles

A slim Zsh setup and an agent stack for macOS, Debian/Ubuntu, and WSL.

The shell provides completion, history, fnm, fzf file previews, and zoxide. Shared PATH rules expose fast CLIs to terminal and agent shells. Claude Code, Codex, and fff-mcp use native binaries. T3 Code launches them through absolute paths.

Read [README.agent.md](README.agent.md) for host detection, install sources, package names, backups, deployment, and validation. WSL provider wiring remains a TODO.

Tracked files live in `shell/` and `agents/`. `scripts/deploy.py` plans absolute symlinks and merges the Codex base while preserving unrelated host settings. `scripts/register-fff.py` plans user-scope MCP registration. Both require Python 3.11+ and apply changes only with `--apply`.

```sh
python3 scripts/deploy.py
```

During an authorized host setup, inspect the plan and run it with `--apply`. Keep credentials and host overrides outside Git. `inventory/` holds host snapshots; do not deploy it.
