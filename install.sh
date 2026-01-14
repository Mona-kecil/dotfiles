#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect OS and architecture
case "$(uname -s)" in
    Linux)  OS="linux" ;;
    Darwin) OS="macos" ;;
    *)      echo "❌ Unsupported OS: $(uname -s)"; exit 1 ;;
esac

case "$(uname -m)" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    arm64)   ARCH="arm64" ;;
    *)       echo "❌ Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

echo "🚀 Installing dotfiles from $DOTFILES_DIR"
echo "   OS: $OS | Arch: $ARCH"

install_linux() {
    echo "📦 Installing packages (Linux)..."
    sudo apt update
    sudo apt install -y \
        git curl zsh tmux unzip build-essential \
        ripgrep fd-find fzf bat eza htop jq wget \
        software-properties-common

    # Neovim (latest from PPA)
    if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -n1 | cut -d' ' -f2 | cut -d'.' -f2)" -lt 10 ]]; then
        echo "📝 Installing Neovim from PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt update
        sudo apt install -y neovim
    fi

    # lazygit
    if ! command -v lazygit &>/dev/null; then
        echo "🦥 Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit /tmp/lazygit.tar.gz
    fi

    # GitHub CLI
    if ! command -v gh &>/dev/null; then
        echo "🐙 Installing GitHub CLI..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        sudo apt update
        sudo apt install -y gh
    fi

    # Go
    GO_VERSION="1.25.5"
    if ! command -v go &>/dev/null; then
        echo "🐹 Installing Go ${GO_VERSION}..."
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
    fi

    # zoxide
    if ! command -v zoxide &>/dev/null; then
        echo "📂 Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # direnv
    if ! command -v direnv &>/dev/null; then
        echo "📁 Installing direnv..."
        curl -sfL https://direnv.net/install.sh | bash
    fi
}

install_macos() {
    echo "📦 Installing packages (macOS)..."

    # Homebrew
    if ! command -v brew &>/dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi

    brew install \
        git curl zsh tmux unzip \
        ripgrep fd fzf bat eza htop jq wget \
        neovim lazygit gh go zoxide direnv
}

install_common() {
    echo "🔧 Installing common tools..."
    mkdir -p "$HOME/.local/bin"

    # Rust
    if ! command -v rustc &>/dev/null; then
        echo "🦀 Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    source "$HOME/.cargo/env" 2>/dev/null || true

    # uv (Python toolchain)
    if ! command -v uv &>/dev/null; then
        echo "🐍 Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Python via uv
    echo "🐍 Installing Python via uv..."
    uv python install
    UV_PYTHON_PATH=$(uv python find 2>/dev/null || true)
    if [ -n "$UV_PYTHON_PATH" ]; then
        ln -sf "$UV_PYTHON_PATH" "$HOME/.local/bin/python3"
        ln -sf "$UV_PYTHON_PATH" "$HOME/.local/bin/python"
    fi

    # ruff & ty
    command -v ruff &>/dev/null || uv tool install ruff
    command -v ty &>/dev/null || uv tool install ty

    # fnm (Node version manager)
    if ! command -v fnm &>/dev/null; then
        echo "⚡ Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash
        export PATH="$HOME/.local/share/fnm:$PATH"
    fi
    eval "$(fnm env 2>/dev/null)" || true

    # Node LTS
    if ! command -v node &>/dev/null; then
        echo "📦 Installing Node LTS..."
        fnm install --lts
        fnm default lts-latest
    fi

    # pnpm
    if ! command -v pnpm &>/dev/null; then
        echo "📦 Installing pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi

    # Bun
    if ! command -v bun &>/dev/null; then
        echo "🍞 Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # tldr
    if ! command -v tldr &>/dev/null; then
        echo "📖 Installing tldr..."
        bun install -g tldr
    fi

    # Amp
    if ! command -v amp &>/dev/null; then
        echo "⚡ Installing Amp..."
        curl -fsSL https://ampcode.com/install.sh | bash
    fi

    # Cargo tools
    command -v tokei &>/dev/null || cargo install tokei
    command -v hyperfine &>/dev/null || cargo install hyperfine
    command -v delta &>/dev/null || cargo install git-delta
    command -v just &>/dev/null || cargo install just

    # Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🐚 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Powerlevel10k
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$p10k_dir" ]; then
        echo "⚡ Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi

    # Zsh plugins
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    [ ! -d "$plugins_dir/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    [ ! -d "$plugins_dir/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"

    # Tmux Plugin Manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "🔌 Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

create_symlinks() {
    echo "🔗 Creating symlinks..."
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

    link() {
        local src="$1" dest="$2"
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            mkdir -p "$backup_dir"
            mv "$dest" "$backup_dir/"
            echo "  📦 Backed up $(basename "$dest")"
        fi
        ln -sfn "$src" "$dest"
        echo "  ✓ $(basename "$src") -> $dest"
    }

    mkdir -p "$HOME/.config"
    link "$DOTFILES_DIR/Neovim" "$HOME/.config/nvim"
    link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    link "$DOTFILES_DIR/Z-Shell/.zshrc" "$HOME/.zshrc"
    link "$DOTFILES_DIR/Z-Shell/.p10k.zsh" "$HOME/.p10k.zsh"
    link "$DOTFILES_DIR/Z-Shell/.tldrrc" "$HOME/.tldrrc"
    link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

    # Zed (optional)
    if [ -d "$HOME/.config/zed" ] || [ "$OS" = "macos" ]; then
        mkdir -p "$HOME/.config/zed"
        link "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
        link "$DOTFILES_DIR/zed/keymap.json" "$HOME/.config/zed/keymap.json"
    fi

    # Ghostty (macOS)
    if [ "$OS" = "macos" ]; then
        mkdir -p "$HOME/.config/ghostty"
        link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
    fi

    [ -d "$backup_dir" ] && echo "  💾 Backups saved to: $backup_dir"
}

set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "🐚 Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
}

main() {
    case "$OS" in
        linux) install_linux ;;
        macos) install_macos ;;
    esac
    install_common
    create_symlinks
    set_default_shell

    echo ""
    echo "✅ Done!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart terminal or run: exec zsh"
    echo "  2. In tmux, press prefix + I to install plugins"
    echo "  3. Open Neovim to let Lazy.nvim install plugins"
}

main "$@"
