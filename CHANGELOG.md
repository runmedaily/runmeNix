# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2026-02-12

### Added
- **Dual-tailscale module** for joining a second tailnet via Docker container
  - Runs on `--network=host` with `--port=41642` to coexist with primary
  - Manual auth via login URL in container logs
- **OSC 52 `yank` function** for copying remote terminal output to local clipboard over SSH
- **Tailscale moved to Docker** — runs as a container with `--network=host` instead of native NixOS service, enabling multi-tailnet support
- **Auth key injection** — primary Tailscale container reads from `/srv/tailscale.env` via `environmentFiles`

### Changed
- Secrets externalized to `.env` (gitignored, baked into ISO at build time)
- Installer writes Tailscale auth key to `/srv/tailscale.env` instead of running `tailscale up` directly
- Makefile stages `.env` temporarily for nix build

## [0.2.0] - 2026-02-11

### Added
- **Homebridge container** with firewall ports and ciao mDNS auto-patching
- **Avahi/mDNS** for HomeKit and Bonjour device discovery
- **HACS** and **Node-RED Companion** auto-seeded into Home Assistant on first boot
- Firewall port ranges for Homebridge child bridges (35000-58000)

### Fixed
- Installer space issues and internet connectivity check

## [0.1.0] - 2026-01-27

### Added
- **Local-flake architecture** — servers keep `/etc/nixos/` local, pull role modules from GitHub
- **Home Assistant role module** with Docker containers:
  - Home Assistant Core on port 8123
  - Node-RED on port 1880 (with HA websocket module pre-installed)
  - Tailscale with `--network=host`
- **Home-manager module** with shared neovim config
- `nrs` alias for flake update + rebuild
- systemd-resolved for split DNS with Tailscale
- Container data directories via tmpfiles

### Changed
- Restructured from centralized `hosts/` to role-based module exports
- Tailscale VPN added to server stack

## [0.0.1] - 2026-01-23

### Added
- Initial release
- Three ISO profiles: Beginner (XFCE), Minimal, Hyprland
- TUI installer with fzf, UEFI/BIOS support
- ZSH with oh-my-zsh, SSH key auth, neofetch
- Makefile for build/test targets
- Tonarchy-inspired XFCE keybindings
- Firefox extensions (uBlock Origin, Dark Reader) in beginner/Hyprland profiles

[0.3.0]: https://github.com/runmedaily/runmeNix/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/runmedaily/runmeNix/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/runmedaily/runmeNix/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/runmedaily/runmeNix/releases/tag/v0.0.1
