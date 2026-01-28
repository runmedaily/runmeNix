{ config, pkgs, lib, ... }:

{
  # Kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Networking
  networking.networkmanager.enable = lib.mkDefault true;

  # SSH
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # DNS - systemd-resolved handles split DNS so Tailscale and public DNS coexist
  services.resolved = {
    enable = lib.mkDefault true;
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Tailscale
  services.tailscale.enable = lib.mkDefault true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # No GUI - terminal only
  services.xserver.enable = lib.mkDefault false;

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
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#default --refresh";
    };
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

  # Starship prompt
  programs.starship.enable = lib.mkDefault true;

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
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
