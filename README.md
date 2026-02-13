# runmeNix

A flake-based NixOS platform for home automation servers and custom installer ISOs.

## Overview

- **Role modules** consumed by servers via local flakes (home-assistant, dual-tailscale)
- **Custom installer ISO** with TUI — partitions disk, sets up user, deploys a role
- **Docker-first services** — Home Assistant, Node-RED, Homebridge, Tailscale all run as containers
- **Multi-tailnet support** — primary + secondary Tailscale for joining separate networks

## Architecture

Servers don't live in this repo. Each server keeps a local flake at `/etc/nixos/` that pulls role modules from GitHub:

```nix
# /etc/nixos/flake.nix on the server
{
  inputs.runmeNix.url = "github:runmedaily/runmeNix";

  outputs = { nixpkgs, runmeNix, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configuration.nix
        ./local.nix
        runmeNix.nixosModules.home-assistant
        runmeNix.nixosModules.dual-tailscale  # optional
      ];
    };
  };
}
```

Rebuild from the server:

```bash
nrs  # alias: nix flake update + nixos-rebuild switch
```

## Role Modules

### `home-assistant`

Full home automation stack:

| Service | Image | Port | Data |
|---------|-------|------|------|
| Home Assistant | `ghcr.io/home-assistant/home-assistant:stable` | 8123 | `/srv/homeassistant` |
| Node-RED | `nodered/node-red:latest` | 1880 | `/srv/nodered` |
| Homebridge | `homebridge/homebridge:latest` | 8581 | `/srv/homebridge` |
| Tailscale | `tailscale/tailscale:latest` | 41641 | `/srv/tailscale` |

Also includes:
- HACS and Node-RED Companion auto-seeded on first boot
- Homebridge auto-patched to use ciao mDNS advertiser
- Avahi for HomeKit/mDNS discovery
- systemd-resolved for split DNS with Tailscale
- ZSH with oh-my-zsh, starship, neofetch
- OSC 52 `yank` function for copying remote output to local clipboard over SSH
- SSH with ed25519 key auth, no passwords

### `dual-tailscale`

Adds a secondary Tailscale container for joining a second tailnet. Runs on `--network=host` with `--port=41642` to avoid conflicts with the primary instance.

- Auth: manual via `sudo docker logs tailscale-secondary` (grab the login URL)
- State: persisted at `/srv/tailscale-secondary`

## Secrets

Secrets are stored in `.env` (gitignored) and baked into the ISO at build time:

```bash
# .env
TAILSCALE_AUTHKEY="tskey-auth-..."
SSH_AUTHORIZED_KEYS=(
  "ssh-ed25519 AAAA... key-name"
)
```

The installer writes `TS_AUTHKEY=...` to `/srv/tailscale.env` for the primary Tailscale container to auto-join on first boot.

## Building the ISO

```bash
git clone https://github.com/runmedaily/runmeNix
cd runmeNix

# Create .env with your secrets (see above)
make build-minimal
# ISO: result/iso/
```

Write to USB:

```bash
lsblk
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot from USB. The installer runs on tty1 and prompts for disk, username, password, and role selection.

## Project Structure

```
runmeNix/
├── flake.nix                  # ISO configs + exported role modules
├── iso.nix                    # Live ISO environment
├── .env                       # Secrets (gitignored, baked into ISO)
├── Makefile                   # Build targets
├── installer/
│   └── install.sh             # TUI installer
├── modules/
│   ├── common.nix             # Shared base config (boot, locale, users, SSH)
│   ├── roles/
│   │   ├── home-assistant.nix # HA + Node-RED + Homebridge + Tailscale
│   │   └── dual-tailscale.nix # Secondary Tailscale for multi-tailnet
│   ├── desktop/
│   │   ├── xfce.nix           # XFCE desktop
│   │   ├── minimal.nix        # Terminal-only
│   │   └── hyprland.nix       # Wayland tiling
│   └── shared/
│       └── server-home.nix    # Home-manager config (neovim, etc.)
└── profiles/                  # Live ISO environments
    ├── beginner.nix
    ├── minimal.nix
    └── hyprland.nix
```

## Remote Clipboard

Servers include a `yank` shell function (OSC 52) for copying output to your local clipboard over SSH:

```bash
sudo docker logs tailscale-secondary 2>&1 | tail -20 | yank
cat /etc/nixos/flake.nix | yank
```

Works with Kitty, iTerm2, and other terminals that support OSC 52.

## License

MIT License - See [LICENSE](LICENSE) for details.
