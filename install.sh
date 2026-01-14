#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Installing dotfiles from $DOTFILES_DIR"

# Install essential packages
install_packages() {
    echo "📦 Installing essential packages..."
    sudo apt update
    sudo apt install -y git curl zsh tmux unzip build-essential \
        ripgrep fd-find fzf bat eza htop jq wget software-properties-common
    
    # Neovim (latest from PPA)
    if ! command -v nvim &> /dev/null || [[ "$(nvim --version | head -n1 | cut -d' ' -f2 | cut -d'.' -f2)" -lt 10 ]]; then
        echo "📝 Installing latest Neovim from PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt update
        sudo apt install -y neovim
    else
        echo "✓ Neovim already up to date"
    fi
}

# Install lazygit
install_lazygit() {
    if ! command -v lazygit &> /dev/null; then
        echo "🦥 Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    else
        echo "✓ lazygit already installed"
    fi
}

# Install tldr
install_tldr() {
    if ! command -v tldr &> /dev/null; then
        echo "📖 Installing tldr..."
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        bun install -g tldr
    else
        echo "✓ tldr already installed"
    fi
}

# Install zoxide
install_zoxide() {
    if ! command -v zoxide &> /dev/null; then
        echo "📂 Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        echo "✓ zoxide already installed"
    fi
}

# Install direnv
install_direnv() {
    if ! command -v direnv &> /dev/null; then
        echo "📁 Installing direnv..."
        curl -sfL https://direnv.net/install.sh | bash
    else
        echo "✓ direnv already installed"
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🐚 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "✓ Oh My Zsh already installed"
    fi
}

# Install Powerlevel10k
install_powerlevel10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$p10k_dir" ]; then
        echo "⚡ Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    else
        echo "✓ Powerlevel10k already installed"
    fi
}

# Install Zsh plugins
install_zsh_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        echo "📝 Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi
    
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        echo "🎨 Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
    fi
}

# Install Tmux Plugin Manager
install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "🔌 Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        echo "✓ TPM already installed"
    fi
}

# Install development tooling
install_tooling() {
    echo "🛠️ Installing development tools..."
    
    # Rust
    if ! command -v rustc &> /dev/null; then
        echo "🦀 Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        echo "✓ Rust already installed"
    fi
    
    # uv (Astral's Python toolchain manager)
    if ! command -v uv &> /dev/null; then
        echo "🐍 Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "✓ uv already installed"
    fi
    
    # Python (latest stable via uv)
    echo "🐍 Installing Python via uv..."
    uv python install
    
    # Create symlinks for python3/pip3 to use uv-managed Python
    mkdir -p "$HOME/.local/bin"
    UV_PYTHON_PATH=$(uv python find 2>/dev/null)
    if [ -n "$UV_PYTHON_PATH" ]; then
        ln -sf "$UV_PYTHON_PATH" "$HOME/.local/bin/python3"
        ln -sf "$UV_PYTHON_PATH" "$HOME/.local/bin/python"
        echo "  ✓ Python symlinked: $UV_PYTHON_PATH"
    fi
    
    # Astral tools: ruff (linter/formatter), ty (type checker)
    if ! command -v ruff &> /dev/null; then
        echo "🔧 Installing ruff..."
        uv tool install ruff
    else
        echo "✓ ruff already installed"
    fi
    
    if ! command -v ty &> /dev/null; then
        echo "🔍 Installing ty (type checker)..."
        uv tool install ty
    else
        echo "✓ ty already installed"
    fi
    
    # fnm (Fast Node Manager)
    if ! command -v fnm &> /dev/null; then
        echo "⚡ Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env)"
    else
        echo "✓ fnm already installed"
    fi
    
    # Node LTS via fnm
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)" 2>/dev/null || true
    if ! command -v node &> /dev/null; then
        echo "📦 Installing Node LTS..."
        fnm install --lts
        fnm default lts-latest
    else
        echo "✓ Node already installed"
    fi
    
    # pnpm
    if ! command -v pnpm &> /dev/null; then
        echo "📦 Installing pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    else
        echo "✓ pnpm already installed"
    fi
    
    # Bun
    if ! command -v bun &> /dev/null; then
        echo "🍞 Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
    else
        echo "✓ Bun already installed"
    fi
    
    # Go
    GO_VERSION="1.25.5"
    if ! command -v go &> /dev/null; then
        echo "🐹 Installing Go ${GO_VERSION}..."
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
    else
        echo "✓ Go already installed ($(go version | cut -d' ' -f3))"
    fi
}

# Install global packages
install_global_packages() {
    echo "🌐 Installing global packages..."
    
    # Amp (AI coding agent)
    if ! command -v amp &> /dev/null; then
        echo "⚡ Installing Amp..."
        curl -fsSL https://ampcode.com/install.sh | bash
    else
        echo "✓ Amp already installed"
    fi
    
    # GitHub CLI
    if ! command -v gh &> /dev/null; then
        echo "🐙 Installing GitHub CLI..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
    else
        echo "✓ GitHub CLI already installed"
    fi
    
    # Cargo tools (tokei, hyperfine, delta, just)
    source "$HOME/.cargo/env" 2>/dev/null || true
    
    if ! command -v tokei &> /dev/null; then
        echo "📊 Installing tokei..."
        cargo install tokei
    else
        echo "✓ tokei already installed"
    fi
    
    if ! command -v hyperfine &> /dev/null; then
        echo "⏱️ Installing hyperfine..."
        cargo install hyperfine
    else
        echo "✓ hyperfine already installed"
    fi
    
    if ! command -v delta &> /dev/null; then
        echo "📝 Installing delta..."
        cargo install git-delta
    else
        echo "✓ delta already installed"
    fi
    
    if ! command -v just &> /dev/null; then
        echo "📋 Installing just..."
        cargo install just
    else
        echo "✓ just already installed"
    fi
}

# Create symlinks with backup
create_symlinks() {
    echo "🔗 Creating symlinks..."
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"
    
    # Backup and link helper function
    link_with_backup() {
        local src="$1"
        local dest="$2"
        
        # If destination exists and is not a symlink, back it up
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            mkdir -p "$backup_dir"
            mv "$dest" "$backup_dir/"
            echo "  📦 Backed up $(basename "$dest") -> $backup_dir/"
        fi
        
        ln -sfn "$src" "$dest"
        echo "  ✓ $(basename "$src") -> $dest"
    }
    
    # Neovim
    mkdir -p "$HOME/.config"
    link_with_backup "$DOTFILES_DIR/Neovim" "$HOME/.config/nvim"
    
    # Tmux
    link_with_backup "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    # Zsh
    link_with_backup "$DOTFILES_DIR/Z-Shell/.zshrc" "$HOME/.zshrc"
    link_with_backup "$DOTFILES_DIR/Z-Shell/.p10k.zsh" "$HOME/.p10k.zsh"
    link_with_backup "$DOTFILES_DIR/Z-Shell/.tldrrc" "$HOME/.tldrrc"
    
    # Git
    link_with_backup "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    
    # Zed (if on a system with Zed)
    if [ -d "$HOME/.config/zed" ] || [ -d "/mnt/c" ]; then
        mkdir -p "$HOME/.config/zed"
        link_with_backup "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
        link_with_backup "$DOTFILES_DIR/zed/keymap.json" "$HOME/.config/zed/keymap.json"
    fi
    
    # Print backup location if any backups were made
    if [ -d "$backup_dir" ]; then
        echo ""
        echo "  💾 Existing configs backed up to: $backup_dir"
        echo "     Copy machine-specific settings to *.local files if needed."
    fi
}

# Set Zsh as default shell
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "🐚 Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
}

# Main
main() {
    mkdir -p "$HOME/.local/bin"
    install_packages
    install_lazygit
    install_tldr
    install_zoxide
    install_direnv
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    install_tpm
    install_tooling
    install_global_packages
    create_symlinks
    set_default_shell
    
    echo ""
    echo "✅ Dotfiles installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Start tmux and press 'prefix + I' to install tmux plugins"
    echo "  3. Open Neovim to let Lazy.nvim install plugins"
}

main "$@"
