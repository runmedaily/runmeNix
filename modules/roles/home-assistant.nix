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
  # DNS - systemd-resolved handles split DNS so Tailscale and public DNS coexist
  services.resolved = {
    enable = lib.mkDefault true;
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Tailscale
  services.tailscale.enable = lib.mkDefault true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

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
      nrs = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#default";
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

  # Docker
  virtualisation.docker.enable = lib.mkDefault true;

  # Ensure container data directories exist with correct ownership
  systemd.tmpfiles.rules = [
    "d /srv/homeassistant 0755 root root -"
    "d /srv/nodered 0755 1000 1000 -"
    "d /srv/homebridge 0755 root root -"
  ];

  # Home Assistant Core container
  virtualisation.oci-containers = {
    backend = "docker";
    containers.homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = [ "/srv/homeassistant:/config" ];
      environment = {
        TZ = config.time.timeZone;
      };
      extraOptions = [ "--network=host" "--privileged" ];
      autoStart = true;
    };

    containers.nodered = {
      image = "nodered/node-red:latest";
      volumes = [ "/srv/nodered:/data" ];
      environment = {
        TZ = config.time.timeZone;
      };
      extraOptions = [ "--network=host" ];
      autoStart = true;
      dependsOn = [ "homeassistant" ];
    };

    containers.homebridge = {
      image = "homebridge/homebridge:latest";
      volumes = [ "/srv/homebridge:/homebridge" ];
      environment = {
        TZ = config.time.timeZone;
        HOMEBRIDGE_CONFIG_UI_PORT = "8581";
      };
      extraOptions = [ "--network=host" ];
      autoStart = true;
    };
  };

  # Seed Node-RED package.json with HA module before container starts
  systemd.services.nodered-seed-packages = {
    description = "Seed Node-RED package.json with Home Assistant module";
    wantedBy = [ "docker-nodered.service" ];
    before = [ "docker-nodered.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      PKGJSON="/srv/nodered/package.json"
      if [ ! -f "$PKGJSON" ]; then
        cat > "$PKGJSON" << 'SEED'
      {
        "name": "nodered-project",
        "description": "Node-RED with Home Assistant",
        "version": "0.0.1",
        "dependencies": {
          "node-red-contrib-home-assistant-websocket": "*"
        }
      }
      SEED
        chown 1000:1000 "$PKGJSON"
      fi
    '';
  };

  # Open service ports: SSH, Home Assistant, Node-RED, HomeKit Bridge, Homebridge UI
  networking.firewall.allowedTCPPorts = [ 22 8123 1880 21064 8581 ];
  # Homebridge main + child bridges use dynamic ports in this range
  networking.firewall.allowedTCPPortRanges = [{ from = 35000; to = 58000; }];
  # mDNS/Bonjour for HomeKit discovery
  networking.firewall.allowedUDPPorts = [ 5353 config.services.tailscale.port ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
