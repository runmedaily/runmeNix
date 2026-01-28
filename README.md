# runmeNix

A custom NixOS minimal ISO and deployable server configurations managed via flakes.

## What This Is

- A **minimal NixOS installer ISO** — terminal-only, no GUI, no profile menus
- **Deployable host configurations** — edit locally, push to remote machines over SSH/Tailscale
- **Flake-based** — reproducible builds, one repo for ISO + host configs

## Quick Start

### Build the ISO

```bash
git clone https://github.com/runmedaily/runmeNix
cd runmeNix

make build-minimal
# ISO will be in result/iso/
```

### Write to USB

```bash
lsblk
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Install

Boot from USB. The installer runs automatically on tty1, or start it manually:

```bash
sudo /etc/nixos-custom/install.sh
```

The installer partitions the disk (UEFI or BIOS), sets up a user with ZSH + oh-my-zsh, SSH key auth, and installs a minimal terminal environment.

## Deploying to Hosts

After initial install, manage hosts remotely from your dev machine:

```bash
# Edit the host config
vim hosts/nixos-ha-server/configuration.nix

# Deploy to the machine
NIX_SSHOPTS="-i ~/.ssh/nixos_custom_iso_ed25519" \
  nixos-rebuild switch \
  --flake .#nixos-ha-server \
  --target-host hanix@<hostname> \
  --sudo --ask-sudo-password
```

Or rebuild from the machine itself:

```bash
sudo nixos-rebuild switch --flake github:runmedaily/runmeNix#nixos-ha-server --refresh
```

## What's Included

The minimal install and host configs provide:

- **ZSH** with oh-my-zsh (robbyrussell theme), autosuggestions, syntax highlighting
- **neofetch** on shell start
- **claude** alias (`nix run github:sadjow/claude-code-nix`)
- **SSH** with ed25519 key auth, no password, no root login
- **Tailscale** VPN
- **Neovim** as default editor (with vi/vim aliases)
- **Starship** prompt
- **Terminal tools**: tmux, git, curl, wget, htop, btop, eza, bat, ripgrep, fd, fzf, ranger

## Project Structure

```
runmeNix/
├── flake.nix              # Flake outputs: ISOs + host configs
├── iso.nix                # Live ISO environment
├── hosts/                 # Deployable machine configurations
│   └── nixos-ha-server/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── profiles/
│   └── minimal.nix        # Live ISO profile
├── modules/
│   ├── common.nix         # Shared base config
│   └── desktop/
│       └── minimal.nix    # Terminal-focused module
└── installer/
    └── install.sh         # TUI installer script
```

## Adding a New Host

1. Create `hosts/<name>/` with `configuration.nix` and `hardware-configuration.nix`
2. Add to `flake.nix`:

```nix
nixosConfigurations.<name> = nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [ ./hosts/<name>/configuration.nix ];
};
```

3. Deploy: `nixos-rebuild switch --flake .#<name> --target-host user@host --sudo --ask-sudo-password`

## First-Time Bootstrap

After a fresh install, the machine needs one manual rebuild to pick up `trusted-users` so remote deploys work:

```bash
# SSH into the machine
ssh -i ~/.ssh/nixos_custom_iso_ed25519 user@<ip>

# Bootstrap from the flake
sudo nixos-rebuild switch --flake github:runmedaily/runmeNix#nixos-ha-server --refresh
```

After this, all future deploys can be done remotely via `--target-host`.

## License

MIT License - See [LICENSE](LICENSE) for details.
