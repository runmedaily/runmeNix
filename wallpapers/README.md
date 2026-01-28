# Wallpapers

This directory contains default wallpapers for the NixOS Custom ISO.

## Default Wallpapers

The system ships with the following wallpapers:

1. **nixos-dark.png** - Dark NixOS-themed wallpaper
2. **nixos-light.png** - Light NixOS-themed wallpaper
3. **minimal.png** - Minimal geometric pattern

## Adding Your Own Wallpapers

To add custom wallpapers to the ISO:

1. Place your wallpaper files (PNG or JPG) in this directory
2. Update the ISO configuration to include them:

```nix
environment.etc."backgrounds/nixos-custom" = {
  source = ./wallpapers;
};
```

3. Rebuild the ISO

## Setting Default Wallpaper

For XFCE, the default wallpaper is set in the profile configuration.
For Hyprland, wallpapers are managed via `swww` or `hyprpaper`.

## Sources

Default wallpapers are sourced from:
- NixOS official artwork: https://github.com/NixOS/nixos-artwork
- Unsplash (CC0 licensed): https://unsplash.com

## License

All wallpapers in this directory are either:
- CC0 (Public Domain)
- CC-BY 4.0 (with attribution)
- Custom created for this project (MIT License)
