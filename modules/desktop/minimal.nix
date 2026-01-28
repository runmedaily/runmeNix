# modules/desktop/minimal.nix - Minimal terminal-focused installation
{ config, pkgs, lib, ... }:

{
  # No GUI by default - pure TTY
  services.xserver.enable = false;

  # Enhanced shell experience
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "systemd" ];
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
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$character"
      ];
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };

  # Neovim as default editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Terminal packages
  environment.systemPackages = with pkgs; [
    # Terminal multiplexers
    tmux
    zellij

    # Modern CLI tools
    eza         # ls replacement
    bat         # cat replacement
    ripgrep     # grep replacement
    fd          # find replacement
    zoxide      # cd replacement
    fzf         # Fuzzy finder
    tldr        # Simplified man pages
    delta       # Git diff viewer
    duf         # df replacement
    dust        # du replacement
    procs       # ps replacement
    bottom      # top replacement
    btop        # Another top replacement
    gping       # ping with graph
    dog         # dig replacement

    # File managers
    ranger
    lf
    yazi

    # Editors
    neovim
    helix

    # Git tools
    git
    gh          # GitHub CLI
    lazygit

    # Development
    direnv
    nix-direnv

    # System monitoring
    htop
    ncdu
    iotop
    nethogs

    # Network tools
    nmap
    tcpdump
    mtr
    bandwhich

    # Text processing
    jq
    yq
    miller

    # Compression
    zstd
    xz
    pigz

    # System info
    neofetch
    fastfetch
    inxi

    # Misc utilities
    tmuxinator
    tealdeer
  ];

  # Better console font
  console = {
    earlySetup = true;
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
    colors = [
      "1d2021" # background
      "cc241d" # red
      "98971a" # green
      "d79921" # yellow
      "458588" # blue
      "b16286" # magenta
      "689d6a" # cyan
      "a89984" # white
      "928374" # bright black
      "fb4934" # bright red
      "b8bb26" # bright green
      "fabd2f" # bright yellow
      "83a598" # bright blue
      "d3869b" # bright magenta
      "8ec07c" # bright cyan
      "ebdbb2" # bright white
    ];
  };

  # Enable direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # SSH agent
  programs.ssh = {
    startAgent = true;
    agentTimeout = "1h";
  };

  # GPG agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };
}
