# Environment Setup for AI Agents

This repository describes the desired terminal and development environment. Adapt installation and configuration to the host instead of assuming one operating system or command name.

## Operating principles

1. Inspect the OS, architecture, shell, package manager, installed commands, and existing configuration before making changes.
2. Present a short plan before beginning.
3. Preserve existing configuration in a timestamped backup before replacing it.
4. Use official package repositories or official installation instructions.
5. Install only the environment declared in this document; do not infer unrelated tools.
6. Make setup idempotent: rerunning it must not duplicate shell initialization or corrupt existing configuration.
7. Keep credentials, tokens, private keys, and machine-specific secrets out of this repository.
8. Validate the completed environment and report changes, skipped steps, and remaining manual actions.

## Detect the host

Distinguish at least:

- macOS
- Native Debian/Ubuntu Linux
- Ubuntu running under WSL

On WSL, treat Windows as the graphical host and WSL as the terminal and development environment.

## Desired environment

### Shell

Install and configure:

- Zsh
- Oh My Zsh
- Powerlevel10k
- `git`, `zsh-syntax-highlighting`, `zsh-autosuggestions`, and `tldr` Oh My Zsh plugins
- fzf
- zoxide
- eza
- bat

Use the repository files:

- `zsh/.zshrc`
- `zsh/.p10k.zsh`
- `zsh/.tldrrc`

Powerlevel10k must use the checked-in configuration. TLDR uses the checked-in Nord theme.

### Terminal multiplexer

Install and configure:

- tmux
- TPM
- Nord tmux theme
- tmux-resurrect
- tmux-continuum

Use `tmux/.tmux.conf` as the source configuration. TPM owns runtime plugins under `~/.tmux/plugins`; do not vendor plugin repositories into this repository.

The tmux prefix is `Ctrl-Space`, not the default `Ctrl-b`.

### Node.js

- Install fnm using its official installation method.
- Let fnm manage the complete Node.js lifecycle.
- Install the current Node.js LTS release and make it the default.
- Use the npm bundled with fnm-managed Node.
- Install TLDR with `npm install --global tldr`.
- Do not add duplicate fnm initialization to Zsh.

### Python

- Install uv using its official installation method.
- Let uv manage Python versions, virtual environments, and Python tools.
- Install a current stable Python through uv.
- Install Ruff and Ty as uv tools.
- Do not create global `python` or `python3` symlinks to uv-managed interpreters.

### General CLI tools

Install:

- Git
- GitHub CLI (`gh`)
- ripgrep
- fd
- btop
- jq
- unzip

### Visual Studio Code

VS Code is the preferred graphical editor.

On macOS:

- Install the VS Code application, preferably with Homebrew Cask.
- Ensure the `code` CLI is available.

On WSL:

- Use the Windows VS Code application; do not install a separate Linux GUI build inside WSL.
- Ensure the Windows `code` CLI is reachable from WSL.
- Install the Microsoft WSL extension (`ms-vscode-remote.remote-wsl`) in the Windows client.
- Allow VS Code to install and manage VS Code Server inside WSL.
- Verify that `code .` from a WSL directory opens a WSL-connected VS Code window.

## Platform-specific names

Do not hide platform differences behind aliases or compatibility symlinks. Configure each consumer to call the command that actually exists on that platform.

### macOS with Homebrew

- Package and command: `bat` / `bat`
- Package and command: `fd` / `fd`
- Configure fzf previews to call `bat`.

### Debian, Ubuntu, and WSL Ubuntu

- Package `bat` provides the `batcat` command.
- Package `fd-find` provides the `fdfind` command.
- Configure fzf previews to call `batcat`.
- Configure any fd integration to call `fdfind` directly.

Before writing configuration, resolve command names with `command -v`. Do not assume package names and executable names match.

## Configuration deployment

Deploy repository configuration with symlinks so the tracked files are the active configuration. Before replacing an existing destination, move it into a timestamped backup directory. Make this process idempotent: an existing correct symlink needs no action.

Required links:

- `~/.zshrc` → `zsh/.zshrc`
- `~/.p10k.zsh` → `zsh/.p10k.zsh`
- `~/.tldrrc` → `zsh/.tldrrc`
- `~/.tmux.conf` → `tmux/.tmux.conf`

Resolve link targets to absolute paths so they remain valid regardless of the current working directory. Report the backup directory and every link created.

Machine-specific shell settings belong in `~/.zshrc.local`, which must not be committed.

## Validation

After setup, verify:

1. Zsh starts without errors and is the intended interactive shell.
2. Powerlevel10k loads the checked-in prompt configuration.
3. All declared Oh My Zsh plugins load.
4. fzf preview uses `bat` on macOS or `batcat` on Debian/Ubuntu.
5. zoxide initializes successfully.
6. `fnm current`, `node --version`, `npm --version`, and `tldr --version` succeed.
7. `uv python list`, `python` execution through `uv run`, `ruff --version`, and `ty --version` succeed.
8. `rg`, the platform-appropriate fd executable, `eza`, the platform-appropriate bat executable, `btop`, `jq`, `unzip`, `git`, and `gh` are available.
9. tmux loads `tmux/.tmux.conf` without errors and TPM installs all declared plugins.
10. `code .` works according to the host model.
11. No duplicate PATH entries or duplicate fnm initialization were introduced.

Finish with a concise report of installed versions, configuration destinations, backup locations, and anything requiring user action.
