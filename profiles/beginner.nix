# profiles/beginner.nix - Full desktop experience for newcomers
{ config, pkgs, lib, ... }:

{
  # Enable X11 and XFCE in live environment
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme.name = "Adwaita-dark";
      };
    };
  };

  # Auto-login to XFCE session
  services.displayManager.autoLogin = {
    enable = true;
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

  # Additional packages for beginner-friendly experience
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty
    kitty

    # File manager
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman

    # Text editors
    xfce.mousepad
    vscodium

    # Media
    vlc
    mpv

    # App launcher
    rofi

    # Utilities
    xfce.xfce4-terminal
    xfce.xfce4-taskmanager
    xfce.xfce4-screenshooter
    xfce.xfce4-pulseaudio-plugin

    # Archive tools
    xarchiver
    file-roller

    # Image viewer
    feh
    sxiv

    # System info
    neofetch
    btop

    # Fonts
    noto-fonts
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    jetbrains-mono
  ];

  # XFCE-specific settings
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # Enable GVFS for trash, network mounts, etc.
  services.gvfs.enable = true;

  # Enable thumbnails
  services.tumbler.enable = true;

  # GTK theming
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  # XFCE keybindings configuration (Tonarchy-style)
  environment.etc."xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-keyboard-shortcuts" version="1.0">
      <property name="commands" type="empty">
        <property name="default" type="empty">
          <property name="&lt;Alt&gt;F2" type="string" value="xfrun4"/>
          <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="string" value="xflock4"/>
        </property>
        <property name="custom" type="empty">
          <!-- Tonarchy-inspired keybindings -->
          <property name="&lt;Super&gt;Return" type="string" value="alacritty"/>
          <property name="&lt;Super&gt;d" type="string" value="rofi -show drun"/>
          <property name="&lt;Super&gt;e" type="string" value="thunar"/>
          <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="alacritty"/>
          <property name="Print" type="string" value="xfce4-screenshooter"/>
        </property>
      </property>
      <property name="xfwm4" type="empty">
        <property name="default" type="empty">
          <property name="&lt;Alt&gt;F4" type="string" value="close_window_key"/>
          <property name="&lt;Alt&gt;Tab" type="string" value="cycle_windows_key"/>
        </property>
        <property name="custom" type="empty">
          <!-- Window management - Tonarchy style -->
          <property name="&lt;Super&gt;q" type="string" value="close_window_key"/>
          <property name="&lt;Super&gt;f" type="string" value="fullscreen_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;f" type="string" value="maximize_window_key"/>
          <property name="&lt;Super&gt;j" type="string" value="cycle_windows_key"/>
          <property name="&lt;Super&gt;k" type="string" value="cycle_reverse_windows_key"/>
          
          <!-- Tiling -->
          <property name="&lt;Super&gt;Left" type="string" value="tile_left_key"/>
          <property name="&lt;Super&gt;Right" type="string" value="tile_right_key"/>
          <property name="&lt;Super&gt;Up" type="string" value="tile_up_key"/>
          <property name="&lt;Super&gt;Down" type="string" value="tile_down_key"/>
          
          <!-- Workspaces -->
          <property name="&lt;Super&gt;1" type="string" value="workspace_1_key"/>
          <property name="&lt;Super&gt;2" type="string" value="workspace_2_key"/>
          <property name="&lt;Super&gt;3" type="string" value="workspace_3_key"/>
          <property name="&lt;Super&gt;4" type="string" value="workspace_4_key"/>
          <property name="&lt;Super&gt;5" type="string" value="workspace_5_key"/>
          <property name="&lt;Super&gt;6" type="string" value="workspace_6_key"/>
          <property name="&lt;Super&gt;7" type="string" value="workspace_7_key"/>
          <property name="&lt;Super&gt;8" type="string" value="workspace_8_key"/>
          <property name="&lt;Super&gt;9" type="string" value="workspace_9_key"/>
          
          <!-- Move to workspace -->
          <property name="&lt;Super&gt;&lt;Shift&gt;1" type="string" value="move_window_workspace_1_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;2" type="string" value="move_window_workspace_2_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;3" type="string" value="move_window_workspace_3_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;4" type="string" value="move_window_workspace_4_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;5" type="string" value="move_window_workspace_5_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;6" type="string" value="move_window_workspace_6_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;7" type="string" value="move_window_workspace_7_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;8" type="string" value="move_window_workspace_8_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;9" type="string" value="move_window_workspace_9_key"/>
          
          <!-- Workspace navigation -->
          <property name="&lt;Super&gt;Tab" type="string" value="workspace_next_key"/>
          <property name="&lt;Super&gt;&lt;Shift&gt;Tab" type="string" value="workspace_prev_key"/>
        </property>
      </property>
    </channel>
  '';

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrains Mono" ];
    };
  };
}
