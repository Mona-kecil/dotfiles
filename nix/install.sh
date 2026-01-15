#!/bin/bash
set -euo pipefail

echo "🚀 Installing Nix + Home Manager"

# Detect OS and set home configuration name
case "$(uname -s)" in
    Linux)
        case "$(uname -m)" in
            x86_64)  CONFIG="monakecil@linux" ;;
            aarch64) CONFIG="monakecil@linux" ;;
            *)       echo "❌ Unsupported architecture"; exit 1 ;;
        esac
        ;;
    Darwin)
        case "$(uname -m)" in
            x86_64)  CONFIG="monakecil@macos-intel" ;;
            arm64)   CONFIG="monakecil@macos-arm" ;;
            *)       echo "❌ Unsupported architecture"; exit 1 ;;
        esac
        ;;
    *)
        echo "❌ Unsupported OS: $(uname -s)"
        exit 1
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Step 1: Install Nix (multi-user/daemon mode)
if ! command -v nix &>/dev/null; then
    echo "📦 Installing Nix (multi-user mode)..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    echo ""
    echo "⚠️  Nix installed. Please restart your shell or run:"
    echo "   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'"
    echo ""
    echo "Then re-run this script to continue."
    exit 0
fi

# Source nix if needed
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

echo "✓ Nix already installed"

# Step 2: Enable flakes (check both user and system config)
FLAKES_ENABLED=false
if grep -q "experimental-features.*flakes" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    FLAKES_ENABLED=true
fi
if grep -q "experimental-features.*flakes" "/etc/nix/nix.conf" 2>/dev/null; then
    FLAKES_ENABLED=true
fi

if [ "$FLAKES_ENABLED" = false ]; then
    echo "⚙️  Enabling flakes..."
    mkdir -p "$HOME/.config/nix"
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
else
    echo "✓ Flakes already enabled"
fi

# Step 3: Install Oh-My-Zsh + plugins (needed for zsh config)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "⚡ Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "📝 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "🎨 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Step 4: Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "🔌 Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Step 5: Apply Home Manager configuration
echo "🏠 Applying Home Manager configuration..."
cd "$SCRIPT_DIR"
nix run home-manager -- switch --flake ".#$CONFIG"

# Step 6: Post-install setup for version managers
echo "🔧 Setting up version managers..."

# Rustup: install default toolchain
if command -v rustup &>/dev/null; then
    if ! rustup show active-toolchain &>/dev/null; then
        echo "🦀 Installing Rust stable toolchain..."
        rustup default stable
    fi
fi

# fnm: install LTS Node
if command -v fnm &>/dev/null; then
    if ! fnm list 2>/dev/null | grep -q "lts"; then
        echo "⚡ Installing Node LTS..."
        eval "$(fnm env)"
        fnm install --lts
        fnm default lts-latest
    fi
fi

# uv: install Python
if command -v uv &>/dev/null; then
    if ! uv python list 2>/dev/null | grep -q "cpython"; then
        echo "🐍 Installing Python..."
        uv python install
    fi
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
fi

echo ""
echo "✅ Done!"
echo ""
echo "Next steps:"
echo "  1. Restart terminal or run: exec zsh"
echo "  2. In tmux, press prefix + I to install plugins"
echo "  3. Open Neovim to let Lazy.nvim install plugins"
