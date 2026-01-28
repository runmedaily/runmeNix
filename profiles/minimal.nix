# profiles/minimal.nix - Lightweight setup for experienced users
{ config, pkgs, lib, ... }:

{
  # No display manager - pure TTY with option to start X manually
  services.xserver.enable = false;

  # Minimal additional packages
  environment.systemPackages = with pkgs; [
    # Terminal multiplexer
    tmux
    zellij

    # Shell enhancements
    zsh
    starship
    zoxide
    eza
    bat
    ripgrep
    fd

    # Editors
    neovim
    helix

    # File manager
    ranger
    lf

    # System monitoring
    btop
    bottom

    # Network tools
    nmap
    tcpdump
    dig

    # Development basics
    git
    gh  # GitHub CLI

    # Compression
    zstd
    xz

    # System info
    neofetch
    fastfetch
  ];

  # ZSH as default shell option
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "systemd" ];
      theme = "robbyrussell";
    };
    interactiveShellInit = ''
      neofetch
    '';
    shellAliases = {
      claude = "nix run github:sadjow/claude-code-nix";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Console improvements
  console = {
    earlySetup = true;
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
  };
}
