# Quick Start Guide

## Building Your First ISO

```bash
# 1. Navigate to the project
cd nixos-custom-iso

# 2. Build the beginner ISO (recommended for first-time users)
make build-beginner

# This will take 10-30 minutes depending on your internet speed
# The ISO will be created in: result/iso/
```

## Testing in QEMU

```bash
# Test the ISO without burning to USB
make test-beginner

# QEMU Tips:
# - Press Ctrl+Alt+G to release mouse
# - Press Ctrl+Alt+F for fullscreen
# - Press Ctrl+Alt+Q to quit
```

## Installation on Real Hardware

```bash
# 1. Find your USB device
lsblk

# 2. Write ISO to USB (CAREFUL - this erases the USB!)
make write-usb

# 3. Boot from USB and run:
sudo /etc/nixos-custom/install.sh

# 4. Follow the TUI installer prompts
```

## What You Get (Beginner Mode)

### Pre-installed Applications
- **Firefox** with uBlock Origin + Dark Reader
- **Alacritty** terminal
- **Thunar** file manager  
- **VLC** media player
- **Rofi** app launcher
- **Neovim** text editor

### Keyboard Shortcuts (Tonarchy-style!)
- `Super + Return` → Terminal
- `Super + D` → App Launcher
- `Super + E` → File Manager
- `Super + Q` → Close Window
- `Super + F` → Fullscreen
- `Super + 1-9` → Switch Workspaces
- `Super + Arrow Keys` → Tile Windows

### System Features
- **Auto-login** enabled (no password on boot)
- **Dark theme** (Adwaita-dark)
- **NetworkManager** for WiFi
- **PipeWire** for audio
- **1GB EFI partition** for multiple kernels

## Profiles Available

### 🟢 Beginner (XFCE)
Full desktop environment, perfect for newcomers
```bash
make build-beginner
```

### 🟡 Minimal (Terminal)
Lightweight, terminal-focused for experienced users
```bash
make build-minimal
```

### 🔵 Hyprland (Wayland)
Modern tiling compositor with eye candy
```bash
make build-hyprland
```

## Common Issues

### "No space left on device"
- You need ~10GB free space to build
- Run: `make clean` to free up space

### "ISO won't boot"
- Check BIOS/UEFI settings
- Disable Secure Boot
- Make sure USB is first in boot order

### "Can't connect to WiFi"
- Use `nmtui` in the terminal
- Or the NetworkManager applet in the system tray

### "Forgot to set password during install"
From the installed system:
```bash
sudo passwd your-username
```

## Next Steps After Installation

1. **Update the system**
   ```bash
   sudo nixos-rebuild switch --upgrade
   ```

2. **Add more software**
   Edit `/etc/nixos/configuration.nix`:
   ```nix
   environment.systemPackages = with pkgs; [
     # Add packages here
     spotify
     discord
     vscode
   ];
   ```

3. **Learn Nix**
   - https://nixos.org/manual/nix/stable/
   - https://nixos.wiki/
   - https://zero-to-nix.com/

## Getting Help

- 📖 Read the full [README.md](README.md)
- 🐛 Check [TODO.md](TODO.md) for known issues
- 💬 Open an issue on GitHub
- 🌟 Star the repo if it helped!

## Build All ISOs

```bash
# Build everything at once
make build-all

# This creates:
# - nixos-beginner-*.iso
# - nixos-minimal-*.iso  
# - nixos-hyprland-*.iso
```

## Pro Tips

1. **Save your configuration**
   After installation, backup `/etc/nixos/configuration.nix`

2. **Use generations**
   NixOS keeps old versions. Rollback with:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

3. **Customize keybindings**
   Edit keybindings in your user XFCE settings after install

4. **Add more Firefox extensions**
   Open Firefox → Extensions → Browse addons

5. **Learn the Super key**
   All shortcuts use Super (Windows key) - memorize them!

---

**Enjoy your new NixOS system! 🎉**

Inspired by [Tonarchy](https://github.com/tonybanters/tonarchy)
