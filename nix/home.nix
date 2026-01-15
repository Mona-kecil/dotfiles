{ config, pkgs, lib, ... }:

{
  home.username = "monakecil";
  home.homeDirectory = 
    if pkgs.stdenv.isDarwin 
    then "/Users/monakecil" 
    else "/home/monakecil";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # ============================================================================
  # PACKAGES ONLY - Configs stay native for easy tinkering
  # ============================================================================
  home.packages = with pkgs; [
    # Shell & Terminal
    zsh
    tmux
    fzf
    zoxide
    direnv

    # Modern CLI replacements
    bat
    eza
    fd
    ripgrep
    delta

    # Git & Dev tools
    git
    gh
    lazygit
    neovim

    # Version managers & language tooling
    rustup      # Rust toolchain manager
    uv          # Python version + package manager
    fnm         # Node.js version manager
    pnpm        # Node package manager
    bun         # JS runtime + bundler

    # Languages
    go

    # Python tools
    ruff        # Python linter
    ty          # Python type checker

    # Utilities
    tokei
    hyperfine
    tldr
    just
    jq
    yq
    curl
    wget
    htop
    unzip
    gnumake     # make
    gcc         # C compiler (build-essential equivalent)

    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # AI
    amp         # AI coding agent
  ];

  # ============================================================================
  # SYMLINK NATIVE CONFIGS
  # Keeps your existing config files - edit them directly, no Nix rebuild needed
  # ============================================================================
  home.file = {
    # Git
    ".gitconfig".source = ../git/.gitconfig;

    # Tmux
    ".tmux.conf".source = ../tmux/.tmux.conf;
    ".tmux".source = ../tmux/.tmux;

    # Zsh (oh-my-zsh installed separately)
    ".zshrc".source = ../Z-Shell/.zshrc;
    ".p10k.zsh".source = ../Z-Shell/.p10k.zsh;
    ".tldrrc".source = ../Z-Shell/.tldrrc;
  };

  xdg.configFile = {
    # Ghostty
    "ghostty/config".source = ../ghostty/config;

    # Zed
    "zed/settings.json".source = ../zed/settings.json;
    "zed/keymap.json".source = ../zed/keymap.json;

    # Neovim - symlink entire directory
    "nvim".source = ../Neovim;
  };

  # ============================================================================
  # MINIMAL SHELL INTEGRATION (just adds Nix to PATH)
  # ============================================================================
  programs.zsh.enable = false;  # We use native .zshrc
  programs.bash.enable = false;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
