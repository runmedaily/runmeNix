# profiles/hyprland.nix - Modern Wayland tiling compositor
{ config, pkgs, lib, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Use greetd with tuigreet for login
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Auto-login for live session
  services.greetd.settings.initial_session = {
    command = "Hyprland";
    user = "nixos";
  };

  # Firefox with extensions for live environment
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    policies = {
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        # Dark Reader
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
      };
    };
  };

  # Hyprland and Wayland packages
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    waybar          # Status bar
    wofi            # App launcher
    rofi-wayland    # Alternative launcher
    dunst           # Notifications
    libnotify
    swww            # Wallpaper daemon
    hyprpaper       # Alternative wallpaper

    # Terminal
    alacritty
    kitty
    foot

    # File manager
    thunar
    yazi            # TUI file manager

    # Screen tools
    grim            # Screenshot
    slurp           # Region selection
    wl-clipboard    # Clipboard
    cliphist        # Clipboard history

    # Screen recording
    wf-recorder
    obs-studio

    # Authentication
    polkit-kde-agent

    # Session management
    wlogout

    # Media (Firefox configured above with extensions)
    mpv
    imv             # Image viewer

    # System
    btop
    neofetch

    # Fonts
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];

  # XDG portal for screen sharing, file dialogs, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable required services
  security.polkit.enable = true;
  services.dbus.enable = true;

  # Session variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrains Mono" ];
    };
  };
}
