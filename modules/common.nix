# modules/common.nix - Shared configuration for all target installations
{ config, pkgs, lib, ... }:

{
  # This module is imported by all target configurations
  # It contains sensible defaults that can be overridden

  # Hardware configuration is generated during installation
  # imports = [ ./hardware-configuration.nix ];

  # Boot loader - systemd-boot for UEFI, GRUB for BIOS
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
    # For BIOS systems, uncomment:
    # grub.enable = true;
    # grub.device = "/dev/sda";
  };

  # Kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Networking
  networking = {
    hostName = lib.mkDefault "nixos";
    networkmanager.enable = lib.mkDefault true;
  };

  # Timezone and locale (can be overridden during installation)
  time.timeZone = lib.mkDefault "America/Los_Angeles";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
  };

  # User configuration (password set during installation)
  users.users.user = {
    isNormalUser = true;
    description = "Default User";
    extraGroups = [
      "wheel"           # Sudo access
      "networkmanager"  # Network management
      "video"           # Video devices
      "audio"           # Audio devices
      "input"           # Input devices
      "storage"         # Storage devices
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwWB/kUbJoBLlUWEtGjLhUwl0PnMO06Uq9MufQxnNrn nixos-custom-iso"
    ];
    # Password will be set during installation
    initialPassword = null;
  };

  # Enable ZSH
  programs.zsh.enable = true;

  # Sudo configuration
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  # Core packages for all installations
  environment.systemPackages = with pkgs; [
    # Essentials
    vim
    neovim
    git
    curl
    wget
    htop
    tree

    # Shell tools
    zsh
    starship
    eza
    bat
    ripgrep
    fd
    fzf

    # System utilities
    pciutils
    usbutils
    lsof
    file

    # Compression
    unzip
    zip
    p7zip
    zstd

    # Network utilities
    dig
    traceroute
  ];

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages (for firmware, drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # Hardware support
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # Sound with PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth (optional)
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };

  # Printing (optional)
  services.printing.enable = lib.mkDefault false;

  # Firewall
  networking.firewall = {
    enable = lib.mkDefault true;
    allowedTCPPorts = [ 22 ];
  };

  # OpenSSH
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # System version
  system.stateVersion = "25.11";
}
