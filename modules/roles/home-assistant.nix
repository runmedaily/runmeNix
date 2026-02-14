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

  # Avahi - mDNS/Bonjour for HomeKit and Homebridge device discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Tailscale runs as a Docker container (allows plugging in a second tailnet)
  services.tailscale.enable = lib.mkForce false;
  boot.kernelModules = [ "tun" ];

  # No GUI - terminal only
  services.xserver.enable = lib.mkDefault false;

  # ZSH
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "systemd" "vi-mode" ];
      theme = "robbyrussell";
    };
    interactiveShellInit = ''
      neofetch

      # OSC 52 remote clipboard - pipe output to yank to copy to local clipboard over SSH
      # Usage: echo "hello" | yank    or    cat file.log | yank
      yank() {
        local data=$(base64 | tr -d '\n')
        printf "\033]52;c;%s\a" "$data"
      }
    '';
    shellAliases = {
      claude = "nix run github:sadjow/claude-code-nix";
      nrs = "test -s /srv/tailscale.env || { echo '!! /srv/tailscale.env is empty or missing — refusing to rebuild. Fix it first.'; return 1; } && echo 'Pre-pulling container images...' && sudo docker pull tailscale/tailscale:latest && sudo docker pull ghcr.io/home-assistant/home-assistant:stable && sudo docker pull nodered/node-red:latest && sudo docker pull homebridge/homebridge:latest && sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#default";
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
    "d /srv/tailscale 0755 root root -"
    "f /srv/tailscale.env 0640 root wheel -"  # must exist for --env-file; wheel-readable so scp backup works
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

    containers.tailscale = {
      image = "tailscale/tailscale:latest";
      volumes = [
        "/srv/tailscale:/var/lib/tailscale"
        "/dev/net/tun:/dev/net/tun"
      ];
      environment = {
        TS_STATE_DIR = "/var/lib/tailscale";
        TS_EXTRA_ARGS = "--advertise-exit-node";
        TS_ACCEPT_DNS = "true";
      };
      environmentFiles = [ "/srv/tailscale.env" ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--network=host"
      ];
      autoStart = true;
    };
  };

  # Don't bounce Tailscale during nixos-rebuild — the container reconnects
  # from persisted state in /srv/tailscale and doesn't need a fresh auth key.
  systemd.services.docker-tailscale.restartIfChanged = false;

  # Migrate native Tailscale state to Docker state dir before container starts.
  # Without this, Docker Tailscale registers as a NEW device and the old IP dies,
  # locking you out of SSH. Only runs once (skips if Docker state already has identity).
  systemd.services.tailscale-migrate-state = {
    description = "Migrate native Tailscale state to Docker container state dir";
    wantedBy = [ "docker-tailscale.service" ];
    before = [ "docker-tailscale.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.docker pkgs.coreutils ];
    script = ''
      NATIVE="/var/lib/tailscale"
      DOCKER="/srv/tailscale"

      # Pre-pull the Tailscale image so the container can start immediately
      if ! docker image inspect tailscale/tailscale:latest >/dev/null 2>&1; then
        echo "Pre-pulling tailscale/tailscale:latest..."
        docker pull tailscale/tailscale:latest
      fi

      # Only migrate if native state exists and Docker state is missing or empty
      if [ -f "$NATIVE/tailscaled.state" ] && [ ! -f "$DOCKER/tailscaled.state" -o ! -s "$DOCKER/tailscaled.state" ]; then
        echo "Migrating native Tailscale state to Docker state dir..."
        cp -a "$NATIVE"/* "$DOCKER"/ 2>/dev/null || true
        chmod -R 755 "$DOCKER"
        chown -R root:root "$DOCKER"
        echo "Migration complete"
      fi

      # Always ensure correct permissions
      chmod 755 "$DOCKER"
    '';
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

  # Seed HACS and Node-RED Companion into Home Assistant before container starts
  systemd.services.homeassistant-seed-hacs = {
    description = "Install HACS and Node-RED Companion into Home Assistant";
    wantedBy = [ "docker-homeassistant.service" ];
    before = [ "docker-homeassistant.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.curl pkgs.unzip pkgs.coreutils ];
    script = ''
      HA_CONFIG="/srv/homeassistant"
      CUSTOM="$HA_CONFIG/custom_components"
      mkdir -p "$CUSTOM"

      # Install HACS
      if [ ! -d "$CUSTOM/hacs" ]; then
        echo "Installing HACS..."
        TMPDIR=$(mktemp -d)
        curl -fsSL -o "$TMPDIR/hacs.zip" "https://github.com/hacs/integration/releases/latest/download/hacs.zip"
        unzip -o "$TMPDIR/hacs.zip" -d "$CUSTOM/hacs"
        rm -rf "$TMPDIR"
        echo "HACS installed"
      fi

      # Install Node-RED Companion
      if [ ! -d "$CUSTOM/nodered" ]; then
        echo "Installing Node-RED Companion..."
        TMPDIR=$(mktemp -d)
        curl -fsSL -o "$TMPDIR/nodered.zip" "https://github.com/zachowj/hass-node-red/releases/latest/download/nodered.zip"
        unzip -o "$TMPDIR/nodered.zip" -d "$CUSTOM/nodered"
        rm -rf "$TMPDIR"
        echo "Node-RED Companion installed"
      fi
    '';
  };

  # Ensure Homebridge uses ciao mDNS advertiser (reliable in Docker)
  systemd.services.homebridge-fix-advertiser = {
    description = "Patch Homebridge config to use ciao mDNS advertiser";
    wantedBy = [ "docker-homebridge.service" ];
    before = [ "docker-homebridge.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.gnused ];
    script = ''
      CFG="/srv/homebridge/config.json"
      if [ -f "$CFG" ]; then
        sed -i 's/"advertiser": "bonjour-hap"/"advertiser": "ciao"/' "$CFG"
      fi
    '';
  };

  # Open service ports: SSH, Home Assistant, Node-RED, HomeKit Bridge, Homebridge UI
  networking.firewall.allowedTCPPorts = [ 22 8123 1880 21064 8581 ];
  # Homebridge main + child bridges use dynamic ports in this range
  networking.firewall.allowedTCPPortRanges = [{ from = 35000; to = 58000; }];
  # mDNS/Bonjour for HomeKit discovery
  networking.firewall.allowedUDPPorts = [ 5353 41641 ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
