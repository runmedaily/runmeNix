# TODO - Items to Consider from Tonarchy

## High Priority

- [ ] Add Firefox extensions (uBlock Origin, Dark Reader) to beginner and Hyprland profiles
- [ ] Configure XFCE keybindings in beginner profile:
  - Super+Return → Alacritty
  - Super+D → Rofi
  - Super+E → Thunar
  - Super+Q → Close window
  - Super+F → Fullscreen
- [ ] Increase EFI partition from 512MB to 1GB (match Tonarchy)
- [ ] Consider switching beginner mode from LightDM to getty autologin (more minimal)

## Medium Priority

- [ ] Add wallpapers directory with default wallpapers
- [ ] Create Makefile for build convenience:
  ```bash
  make build-beginner
  make build-minimal
  make build-hyprland
  make test
  ```
- [ ] Add ASCII art logo for installer banner
- [ ] Consider adding an "Oxidized" profile with a minimal tiling WM (maybe LeftWM or i3)

## Low Priority

- [ ] Add GitHub Actions for automated ISO builds
- [ ] Add encrypted disk support (LUKS)
- [ ] Add Btrfs with snapshots option
- [ ] Multi-disk configuration support
- [ ] Add flake.lock file (currently missing)

## NixOS-Specific Enhancements

- [ ] Consider using home-manager for user-level configurations
- [ ] Add option to generate user dotfiles during installation
- [ ] Create systemd service for first-boot configuration wizard
- [ ] Add option to enable automatic system updates

## Documentation

- [ ] Add screenshots to README
- [ ] Create wiki or extended docs
- [ ] Add troubleshooting guide
- [ ] Document how to customize profiles
