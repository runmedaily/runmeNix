# modules/desktop/hyprland.nix - Hyprland Wayland compositor
{ config, pkgs, lib, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # XDG portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Security/Authentication
  security.polkit.enable = true;
  services.dbus.enable = true;

  # Firefox with extensions
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

  # Hyprland ecosystem packages
  environment.systemPackages = with pkgs; [
    # Wayland core
    waybar           # Status bar
    wofi             # App launcher
    rofi-wayland     # Alternative launcher
    dunst            # Notifications
    libnotify
    swww             # Wallpaper
    hyprpaper        # Alternative wallpaper
    hyprlock         # Lock screen
    hypridle         # Idle daemon

    # Terminal
    alacritty
    kitty
    foot

    # File manager
    thunar
    yazi
    nautilus

    # Screenshots/Recording
    grim
    slurp
    wl-clipboard
    cliphist
    wf-recorder
    obs-studio

    # Browser (Firefox configured above with extensions)
    chromium

    # Media
    mpv
    imv
    vlc

    # Text editors
    neovim
    vscodium

    # System utilities
    btop
    pavucontrol      # Audio control
    networkmanagerapplet
    blueman          # Bluetooth

    # Theme/Appearance
    nwg-look         # GTK settings
    qt5ct
    qt6ct

    # Authentication agent
    polkit-kde-agent

    # Session management
    wlogout

    # System info
    neofetch
    fastfetch

    # Fonts
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
  ];

  # Environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # Thunar plugins
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # GVFS for file manager
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      jetbrains-mono
      inter
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
      };
    };
  };

  # Default Hyprland config (user can override in ~/.config/hypr/hyprland.conf)
  environment.etc."hypr/hyprland.conf.default".text = ''
    # Default Hyprland configuration
    # Copy to ~/.config/hypr/hyprland.conf and customize
    
    # Monitor configuration (auto-detect)
    monitor=,preferred,auto,auto
    
    # Execute at launch
    exec-once = waybar
    exec-once = dunst
    exec-once = swww-daemon
    exec-once = /usr/lib/polkit-kde-authentication-agent-1
    
    # Input configuration
    input {
      kb_layout = us
      follow_mouse = 1
      touchpad {
        natural_scroll = true
      }
      sensitivity = 0
    }
    
    # General settings
    general {
      gaps_in = 5
      gaps_out = 10
      border_size = 2
      col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
      col.inactive_border = rgba(595959aa)
      layout = dwindle
    }
    
    # Decoration
    decoration {
      rounding = 10
      blur {
        enabled = true
        size = 3
        passes = 1
      }
      drop_shadow = true
      shadow_range = 4
      shadow_render_power = 3
    }
    
    # Animations
    animations {
      enabled = true
      bezier = myBezier, 0.05, 0.9, 0.1, 1.05
      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
    }
    
    # Dwindle layout
    dwindle {
      pseudotile = true
      preserve_split = true
    }
    
    # Keybindings
    $mainMod = SUPER
    
    bind = $mainMod, Return, exec, alacritty
    bind = $mainMod, Q, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, E, exec, thunar
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, D, exec, wofi --show drun
    bind = $mainMod, P, pseudo,
    bind = $mainMod, J, togglesplit,
    bind = $mainMod, F, fullscreen,
    
    # Screenshot
    bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
    bind = SHIFT, Print, exec, grim - | wl-copy
    
    # Move focus
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d
    
    # Workspaces
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10
    
    # Move to workspace
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10
    
    # Scroll through workspaces
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1
    
    # Move/resize with mouse
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
  '';
}
