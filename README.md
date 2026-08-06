# Dotfiles

Personal Zsh and tmux configuration for macOS, Linux, and WSL.

> **AI agents:** Read [`README.agent.md`](README.agent.md) for the complete setup specification and validation checklist.

## What this sets up

### Shell

- **Zsh + Oh My Zsh** — interactive shell and plugin framework
- **Powerlevel10k** — prompt theme using the checked-in configuration
- **fzf** — fuzzy history and file search
- **zoxide** — directory navigation that learns frequently used paths
- **eza** — friendlier file listings
- **bat** — syntax-highlighted file previews
- **TLDR** — concise command examples with a Nord theme

### Development

- **fnm** manages Node.js, npm, and Node versions
- **uv** manages Python versions, virtual environments, Ruff, and Ty
- **GitHub CLI** provides GitHub access from the terminal
- **ripgrep** and **fd** provide fast text and file searching

Linux executable names can differ from macOS. For example, Ubuntu packages expose `batcat` and `fdfind` instead of `bat` and `fd`; the setup accounts for these differences directly.

### Utilities

- **btop** — friendly system-resource and process monitor
- **jq** — JSON processor
- **unzip** — ZIP archive extraction

### VS Code

VS Code is the preferred graphical editor. On WSL, the Windows VS Code application connects to the Linux environment through the Microsoft WSL extension and its managed VS Code Server.

## tmux preferences

The tmux leader is **`Ctrl-Space`** instead of `Ctrl-b`.

Useful bindings:

| Binding | Action |
|---|---|
| `Ctrl-Space v` | Split side by side |
| `Ctrl-Space s` | Split top and bottom |
| `Ctrl-Space t` | Open scratch-terminal popup |
| `Ctrl-d` | Close the scratch terminal |
| `Ctrl-Space <` / `>` | Reorder panes |
| `Ctrl-Space w` | Full-screen session/window chooser |
| `Ctrl-Space r` | Reload configuration |
| `Ctrl-h/j/k/l` | Move between panes without the leader |

Sessions are automatically saved and restored with tmux-continuum and tmux-resurrect.

## Repository layout

```text
.
├── zsh/
│   ├── .zshrc
│   ├── .p10k.zsh
│   └── .tldrrc
├── tmux/
│   └── .tmux.conf
├── README.md
└── README.agent.md
```

The active configuration files are symlinked from the home directory into this repository, so edits stay synchronized with Git.

## Setup

Give your AI coding assistant this repository and ask:

> Read `README.agent.md`, inspect this machine, and set up the declared environment.

The agent guide contains platform-specific installation, configuration, backup, and validation instructions.