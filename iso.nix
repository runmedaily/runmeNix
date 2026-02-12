# iso.nix - Core configuration for the live ISO environment
{ config, pkgs, lib, self, ... }:

{
  # System version
  system.stateVersion = "25.11";

  # Disable ZFS (currently broken in 25.11)
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" ];

  # ISO image settings
  isoImage = {
    # Make the ISO EFI-bootable
    makeEfiBootable = true;
    # Make the ISO BIOS-bootable
    makeUsbBootable = true;
    # Squashfs compression
    squashfsCompression = "zstd -Xcompression-level 19";
  };

  # Boot settings for live environment
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Plymouth boot splash (optional, comment out for faster boot)
    # plymouth.enable = true;
  };

  # Network configuration for live environment
  networking = {
    hostName = "nixos-installer";
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false; # Use NetworkManager instead
  };

  # Auto-login for live session
  services.getty.autologinUser = "nixos";

  # Core packages available in the live environment
  environment.systemPackages = with pkgs; [
    # Essentials
    vim
    neovim
    git
    curl
    wget
    htop
    tree

    # Disk tools
    gparted
    parted
    dosfstools
    e2fsprogs
    btrfs-progs
    ntfs3g

    # Network tools
    networkmanager
    wpa_supplicant

    # TUI tools for installer
    fzf
    dialog
    gum  # Modern TUI toolkit

    # File managers
    ranger
    mc

    # Hardware info
    pciutils
    usbutils
    lshw
    dmidecode

    # Archive tools
    unzip
    zip
    p7zip
  ];

  # Copy target configurations to the ISO
  environment.etc = {
    # Make target configurations available
    "nixos-custom/configurations".source = ./modules;
    "nixos-custom/profiles".source = ./profiles;

    # Copy the installer script
    "nixos-custom/install.sh" = {
      source = ./installer/install.sh;
      mode = "0755";
    };

    # Secrets (from .env, gitignored)
    "nixos-custom/.env" = lib.mkIf (builtins.pathExists ./.env) {
      source = ./.env;
      mode = "0600";
    };

    # Helper script to launch installer
    "nixos-custom/README.txt".text = ''
      ╔══════════════════════════════════════════════════════════════╗
      ║           NixOS Custom Installer - Inspired by Tonarchy      ║
      ╠══════════════════════════════════════════════════════════════╣
      ║                                                              ║
      ║  To start the installer, run:                                ║
      ║                                                              ║
      ║    sudo /etc/nixos-custom/install.sh                         ║
      ║                                                              ║
      ║  Or for the TUI installer:                                   ║
      ║                                                              ║
      ║    sudo nixos-custom-install                                 ║
      ║                                                              ║
      ╚══════════════════════════════════════════════════════════════╝

      Available profile:
      - minimal : Lightweight terminal-focused setup

      Manual installation:
      1. Partition your disk (use gparted or parted)
      2. Mount partitions to /mnt
      3. Generate config: nixos-generate-config --root /mnt
      4. Edit /mnt/etc/nixos/configuration.nix
      5. Install: nixos-install
    '';
  };

  # Create the custom installer command
  environment.shellAliases = {
    install = "sudo /etc/nixos-custom/install.sh";
    nixos-custom-install = "sudo /etc/nixos-custom/install.sh";
  };

  # Auto-launch installer on tty1 after login
  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ] && [ -z "$INSTALLER_LAUNCHED" ]; then
      export INSTALLER_LAUNCHED=1
      sudo /etc/nixos-custom/install.sh
    fi
  '';

  # Enable SSH for remote installation (optional)
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Set a default password for the live user (change in production!)
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # Password: nixos (you should change this or use hashedPassword)
    password = "nixos";
    initialHashedPassword = lib.mkForce null;
  };

  # Allow passwordless sudo for wheel group in live environment
  security.sudo.wheelNeedsPassword = false;

  # Timezone (will be set during installation)
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Console settings
  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Binary caches for faster builds
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Garbage collection
    gc.automatic = false; # Don't run GC in live environment
  };

  # Hardware support
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # Sound (for desktop profiles)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
