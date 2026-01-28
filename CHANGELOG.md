# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Firefox extensions (uBlock Origin, Dark Reader) pre-installed in beginner and Hyprland profiles
- Tonarchy-inspired XFCE keybindings:
  - Super+Return for terminal
  - Super+D for app launcher (Rofi)
  - Super+E for file manager
  - Super+Q to close windows
  - Super+F for fullscreen
  - Super+1-9 for workspace switching
  - Super+Shift+1-9 to move windows to workspaces
  - Super+Tab/Shift+Tab for workspace navigation
  - Super+Arrow keys for window tiling
- Makefile for convenient building and testing:
  - `make build-beginner`, `make build-minimal`, `make build-hyprland`
  - `make test-*` targets for QEMU testing
  - `make clean`, `make dev`, `make update` utilities
- Custom ASCII art logo (logo.txt)
- Wallpapers directory structure with README
- TODO.md for tracking future improvements

### Changed
- Increased EFI partition size from 512MB to 1GB (matching Tonarchy)
- Updated README.md with new features and Makefile documentation
- Improved documentation in profiles and modules

### Fixed
- N/A

## [0.1.0] - 2026-01-23

### Added
- Initial release
- Three installation profiles: Beginner (XFCE), Minimal, Hyprland
- TUI installer with fzf integration
- UEFI and BIOS support
- Automatic partitioning and installation
- NixOS 25.11 based
- Flakes enabled by default

[Unreleased]: https://github.com/yourusername/nixos-custom-iso/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/nixos-custom-iso/releases/tag/v0.1.0
