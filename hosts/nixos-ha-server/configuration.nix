{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot loader (BIOS/GRUB)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking — hostname is set per-machine during install, not overridden here
  networking.networkmanager.enable = true;

  # Time and Locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console
  console.keyMap = "us";

  # User account
  users.users.hanix = {
    isNormalUser = true;
    description = "hanix";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwWB/kUbJoBLlUWEtGjLhUwl0PnMO06Uq9MufQxnNrn nixos-custom-iso"
    ];
  };

  # Create .zshrc to prevent zsh-newuser-install wizard
  system.activationScripts.zshrc = ''
    for dir in /home/*; do
      user=$(basename "$dir")
      if [ -d "$dir" ] && ! [ -f "$dir/.zshrc" ]; then
        echo "# Managed by NixOS - system zsh config is in /etc/zshrc" > "$dir/.zshrc"
        chown "$user:users" "$dir/.zshrc"
      fi
    done
  '';

  # No GUI - terminal only
  services.xserver.enable = false;

  # ZSH
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

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Starship prompt
  programs.starship.enable = true;

  # Terminal packages
  environment.systemPackages = with pkgs; [
    tmux git curl wget htop btop neofetch
    eza bat ripgrep fd fzf ranger starship
    cowsay
    kitty.terminfo
  ];

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System version - DO NOT CHANGE
  system.stateVersion = "25.11";
}
