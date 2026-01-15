# Nix Home Manager Configuration

**Philosophy**: Nix manages packages, native configs stay native for easy tinkering.

- ✅ Packages: Installed and versioned by Nix (reproducible)
- ✅ Configs: Your existing files, symlinked (edit directly, no rebuild)

## Quick Install

```bash
cd ~/code/dotfiles/nix
./install.sh
```

This automatically:
1. Installs Nix with flakes enabled
2. Installs Oh-My-Zsh + Powerlevel10k + plugins
3. Installs Tmux Plugin Manager
4. Applies Home Manager configuration
5. Sets up Rust (stable), Node (LTS), Python via version managers
6. Sets zsh as default shell

## What Nix Manages

**All packages:**
- CLI tools: bat, eza, fd, ripgrep, fzf, zoxide, delta, lazygit, etc.
- Dev tools: git, gh, neovim, tmux, go
- Version managers: rustup, fnm, uv
- Package managers: pnpm, bun
- Fonts: FiraCode Nerd Font

## Daily Usage

| Task | Command |
|------|---------|
| Add/remove packages | Edit `home.nix`, then `home-manager switch --flake .#...` |
| Edit configs | Just edit the native files directly (no rebuild needed!) |
| List generations | `home-manager generations` |
| Rollback packages | `home-manager switch --rollback` |
| Update all packages | `nix flake update && home-manager switch --flake .#...` |
| Garbage collect | `nix-collect-garbage -d` |
| Try package temporarily | `nix-shell -p <package>` |

## Config Files (Native)

Edit these directly—changes apply immediately (no Nix rebuild):

| Config | Location |
|--------|----------|
| Git | `git/.gitconfig` |
| Tmux | `tmux/.tmux.conf` |
| Zsh | `Z-Shell/.zshrc` |
| Neovim | `Neovim/` |
| Ghostty | `ghostty/config` |
| Zed | `zed/settings.json` |

## Version Manager Usage

These are installed by Nix but manage their own versions:

```bash
# Rust
rustup default stable
rustup update

# Node.js
fnm install 20
fnm use 20
fnm default 20

# Python
uv python install 3.12
uv python pin 3.12

# Bun (self-updates)
bun upgrade
```

## Adding Packages

```nix
# home.nix
home.packages = with pkgs; [
  # ... existing
  httpie     # ← just add here
  duf
];
```

Then: `home-manager switch --flake .#monakecil@linux`

Search packages: `nix search nixpkgs <name>`

## Manual Commands (if needed)

```bash
# Linux
home-manager switch --flake .#monakecil@linux

# macOS Apple Silicon
home-manager switch --flake .#monakecil@macos-arm

# macOS Intel
home-manager switch --flake .#monakecil@macos-intel
```
