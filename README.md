# Dotfiles
My personal configurations

## Quick Install

```bash
git clone https://github.com/Mona-kecil/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

## Cheatsheet

### CLI Tools

| Tool | Command | Description |
|------|---------|-------------|
| **eza** | `ls`, `ll`, `la`, `lt` | Modern ls with icons, git status, tree view |
| **zoxide** | `z <partial-path>` | Smart cd that learns your habits |
| **fzf** | `Ctrl+R`, `Ctrl+T` | Fuzzy finder for history, files |
| **bat** | `bat <file>` | Better cat with syntax highlighting |
| **ripgrep** | `rg <pattern>` | Fast grep (used by Neovim telescope) |
| **fd** | `fdu <pattern>` | Fast find |
| **lazygit** | `lg` | Terminal UI for git |
| **tldr** | `tldr <command>` | Simplified man pages |
| **htop** | `htop` | Better top/process viewer |
| **jq** | `jq` | JSON processor |
| **direnv** | auto | Auto-load `.envrc` per directory |
| **[amp](https://ampcode.com)** | `amp` | AI coding agent |
| **[gh](https://cli.github.com)** | `gh` | GitHub CLI |
| **[tokei](https://github.com/XAMPPRocky/tokei)** | `loc` | Fast code line counter |
| **[hyperfine](https://github.com/sharkdp/hyperfine)** | `bench` | CLI benchmarking |
| **[delta](https://github.com/dandavison/delta)** | auto (git pager) | Better git diffs |
| **[just](https://github.com/casey/just)** | `j` | Modern Makefile alternative |

### Aliases

| Alias | Command |
|-------|---------|
| `v` | `nvim` |
| `g` | `git` |
| `gs` | `git status` |
| `gp` | `git push` |
| `gc` | `git commit` |
| `lg` | `lazygit` |
| `a` | `source activate` |
| `da` | `deactivate` |
| `tks` | `tmux kill-server` |
| `tls` | `tmux ls` |
| `loc` | `tokei` (count lines of code) |
| `bench` | `hyperfine` (benchmark commands) |
| `j` | `just` (run justfile recipes) |

### Git Aliases (in .gitconfig)

| Alias | Command |
|-------|---------|
| `git co` | `checkout` |
| `git br` | `branch` |
| `git st` | `status` |
| `git cm "msg"` | `commit -m "msg"` |
| `git lg` | Pretty log graph |
| `git undo` | Undo last commit (keep changes) |
| `git unstage` | Unstage all files |

### direnv Usage

Create `.envrc` in any project:
```bash
export DATABASE_URL="postgres://localhost/mydb"
export API_KEY="secret"
```
Then run `direnv allow`. Vars auto-load on `cd`.

### Tmux

- Prefix: `Ctrl+Space`
- Install plugins: `prefix + I`
- Save session: `prefix + Ctrl+s`
- Restore session: `prefix + Ctrl+r`

### Neovim

Plugins auto-install on first launch via Lazy.nvim.

### gh (GitHub CLI)

```bash
gh auth login          # Authenticate with GitHub
gh repo clone <repo>   # Clone a repo
gh pr create           # Create a pull request
gh pr checkout <num>   # Checkout a PR
gh issue list          # List issues
gh browse              # Open repo in browser
```

### tokei (Lines of Code)

```bash
loc                    # Count lines in current dir
loc src/               # Count lines in specific dir
loc --files            # Show file-by-file breakdown
```

### hyperfine (Benchmarking)

```bash
bench 'command'                    # Benchmark a command
bench 'cmd1' 'cmd2'                # Compare two commands
bench --warmup 3 'command'         # Run 3 warmup runs first
bench --export-markdown out.md 'cmd'  # Export results
```

### just (Task Runner)

Create a `justfile` in your project:
```just
build:
    cargo build --release

test:
    cargo test

dev:
    cargo watch -x run
```

Then run with `j build`, `j test`, etc.

## Contents
- Configuration for [Neovim](https://neovim.io/)
- Configuration for [Tmux](https://github.com/tmux/tmux/wiki)
- Configuration for [Zsh](https://www.zsh.org/)
- Configuration for [Ghostty](https://ghostty.org/)
- Tooling for Rust, Python, JS

## Fonts
use [Nerd Fonts](https://nerdfonts.com).
I personally use [Fira Code Nerd Font w/ligatures](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip)

## Color theme
Nord

## Neovim
### Plugins (other than the ones from Kickstart.nvim)
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)
- [nord](https://github.com/shaunsingh/nord.nvim)

- [tw_colorizer](https://github.com/roobert/tailwindcss-colorizer-cmp.nvim)

### Mason (LSPs, Formatters, Linters)

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| TypeScript/JS | [vtsls](https://github.com/yioneko/vtsls) | prettier | [oxlint](https://oxc.rs/docs/guide/usage/linter.html) |
| Python | pylsp | black, isort | ruff |
| Rust | rust-analyzer | rustfmt | - |
| Go | gopls | gofumpt, goimports | golangci-lint |
| HTML | html | prettier | - |
| Tailwind | tailwindcss | - | - |
| Lua | lua_ls | stylua | - |

### VoidZero Tooling

Using [oxlint](https://oxc.rs/docs/guide/usage/linter.html) for JS/TS linting (50-100x faster than ESLint).

For formatting, consider [oxfmt](https://oxc.rs/docs/guide/usage/formatter) (30x faster than Prettier):
```bash
npx oxfmt .
```

## Tmux
### Plugins
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Nord Tmux](https://github.com/arcticicestudio/nord-tmux)
- [Tmux Ressurect](https://github.com/tmux-plugins/tmux-resurrect)
- [Tmux Continuum](https://github.com/tmux-plugins/tmux-continuum)

## Zsh
### Plugins
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- zsh-autosuggestions
- zsh-syntax-highlighting
- git

## For Rust
- [rust](https://rust-lang.org/)

## Tooling for Python
- [uv](https://astral.sh)

## Tooling for JavaScript
- [Bun](https://bun.sh/)
- [PNPM](https://pnpm.io/)
