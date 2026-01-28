# NixOS Custom ISO

A custom NixOS installation ISO with a TUI installer, inspired by [Tonarchy](https://github.com/tonybanters/tonarchy).

## Philosophy

This project provides **opinionated installation modes** that take users from zero to hero:

- **Beginner Mode**: Full XFCE desktop with sensible defaults - no choices, no confusion
- **Minimal Mode**: Lightweight terminal-focused setup for experienced users
- **Hyprland Mode**: Modern Wayland tiling compositor for those who want cutting-edge

## Features

- 🎯 **Opinionated Profiles**: Pre-configured desktop environments
- 🖥️ **TUI Installer**: Interactive terminal installer with fzf integration
- ⚡ **NixOS 25.11**: Latest stable NixOS release
- 🔧 **UEFI + BIOS**: Support for both boot modes
- 📦 **Flakes**: Modern Nix with flakes enabled by default
- 🔑 **Tonarchy-Inspired Keybindings**: Consistent Super-key shortcuts across profiles
- 🦊 **Pre-configured Firefox**: uBlock Origin and Dark Reader pre-installed
- 🎨 **Dark Theme**: Adwaita-dark out of the box

## Quick Start

### Mac Users: Start Here! 🍎

If you're on macOS, run the setup helper first:

```bash
cd nixos-custom-iso
./setup-mac.sh
```

Then see **[TESTING-ON-MAC.md](TESTING-ON-MAC.md)** for detailed instructions on using UTM or QEMU.

### Build the ISO

```bash
# Clone the repository
git clone https://github.com/yourusername/nixos-custom-iso
cd nixos-custom-iso

# Using Makefile (recommended)
make build-beginner   # Build XFCE ISO
make build-minimal    # Build minimal ISO
make build-hyprland   # Build Hyprland ISO
make build-all        # Build all ISOs

# Or using nix directly
nix build .#nixosConfigurations.iso-beginner.config.system.build.isoImage
nix build .#nixosConfigurations.iso-minimal.config.system.build.isoImage
nix build .#nixosConfigurations.iso-hyprland.config.system.build.isoImage

# ISO will be in result/iso/
ls result/iso/
```

### Test in QEMU

```bash
# Using Makefile (recommended)
make test-beginner   # Test beginner ISO
make test-minimal    # Test minimal ISO
make test-hyprland   # Test Hyprland ISO

# Or manually
nix develop
qemu-system-x86_64 -enable-kvm -m 4G -cdrom result/iso/*.iso
```

### Write to USB

```bash
# Find your USB device
lsblk

# Write ISO (replace /dev/sdX with your USB device)
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Installation Modes

### Beginner (XFCE)

Perfect for your first Linux installation:

- XFCE desktop with Adwaita-dark theme
- Auto-login enabled
- Firefox with uBlock Origin and Dark Reader pre-installed
- Alacritty terminal, Thunar file manager, VLC media player
- Rofi app launcher with Super+D keybinding
- Neovim for editing
- NetworkManager for easy network configuration
- Tonarchy-inspired keybindings (Super+Return, Super+E, Super+Q, etc.)

### Minimal (Terminal)

For experienced users who prefer the command line:

- No GUI - pure TTY
- ZSH with syntax highlighting and autosuggestions
- Starship prompt
- Modern CLI tools: eza, bat, ripgrep, fd, fzf
- tmux/zellij for terminal multiplexing
- Neovim as default editor

### Hyprland (Wayland)

Modern tiling compositor with eye candy:

- Hyprland compositor
- Waybar, Wofi, Dunst
- Alacritty/Kitty terminals
- Screenshot tools (grim, slurp)
- Beautiful default configuration

## Project Structure

```
nixos-custom-iso/
├── flake.nix              # Main flake definition
├── iso.nix                # ISO-specific configuration
├── profiles/              # Live environment profiles
│   ├── beginner.nix       # XFCE live environment
│   ├── minimal.nix        # Minimal live environment
│   └── hyprland.nix       # Hyprland live environment
├── modules/               # Target system modules
│   ├── common.nix         # Shared configuration
│   └── desktop/
│       ├── xfce.nix       # XFCE target config
│       ├── minimal.nix    # Minimal target config
│       └── hyprland.nix   # Hyprland target config
└── installer/
    └── install.sh         # TUI installer script
```

## Keybindings

### XFCE (Beginner Mode)

| Key | Action |
|-----|--------|
| `Super+Return` | Terminal (Alacritty) |
| `Super+D` | App Launcher (Rofi) |
| `Super+E` | File Manager (Thunar) |
| `Super+Q` | Close Window |
| `Super+F` | Fullscreen |
| `Super+1-9` | Switch Workspace |

### Hyprland Mode

| Key | Action |
|-----|--------|
| `Super+Return` | Terminal (Alacritty) |
| `Super+D` | App Launcher (Wofi) |
| `Super+E` | File Manager (Thunar) |
| `Super+Q` | Close Window |
| `Super+F` | Fullscreen |
| `Super+V` | Toggle Floating |
| `Super+1-9` | Switch Workspace |
| `Super+Shift+1-9` | Move to Workspace |
| `Print` | Screenshot (region) |
| `Shift+Print` | Screenshot (full) |

## Customization

### Adding Packages

Edit the relevant profile in `profiles/` or module in `modules/desktop/`:

```nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  spotify
  discord
  vscode
];
```

### Changing Defaults

Most settings use `lib.mkDefault` and can be overridden. Create a custom profile or modify existing ones.

### Creating a New Profile

1. Create a new file in `profiles/` (e.g., `profiles/gaming.nix`)
2. Add it to `flake.nix`:

```nix
iso-gaming = mkIso {
  profile = ./profiles/gaming.nix;
  isoName = "nixos-gaming-${self.shortRev or "dev"}";
  volumeID = "NIXOS_GAME";
};
```

## Disk Layout

### UEFI Systems

| Partition | Size | Type | Mount |
|-----------|------|------|-------|
| 1 | 1GB | FAT32 (ESP) | /boot |
| 2 | 4GB (configurable) | swap | - |
| 3 | Remaining | ext4 | / |

### BIOS Systems

| Partition | Size | Type | Mount |
|-----------|------|------|-------|
| 1 | 4GB (configurable) | swap | - |
| 2 | Remaining | ext4 (bootable) | / |

## Requirements

- UEFI or BIOS system
- 4GB+ RAM (8GB recommended for Hyprland)
- 20GB+ disk space
- Internet connection

## Makefile Commands

The project includes a Makefile for convenience:

```bash
make help              # Show all available commands
make build-beginner    # Build beginner (XFCE) ISO
make build-minimal     # Build minimal ISO
make build-hyprland    # Build Hyprland ISO
make build-all         # Build all ISOs
make test-beginner     # Test beginner ISO in QEMU
make test-minimal      # Test minimal ISO in QEMU
make test-hyprland     # Test Hyprland ISO in QEMU
make clean             # Remove build artifacts
make dev               # Enter development shell
make update            # Update flake inputs
make check             # Check flake validity
```

## Roadmap

- [x] XFCE Beginner Mode
- [x] Minimal Mode
- [x] Hyprland Mode
- [x] UEFI support
- [x] BIOS support
- [x] Tonarchy-inspired keybindings
- [x] Firefox with pre-installed extensions
- [x] Makefile for build convenience
- [ ] Encrypted disk support (LUKS)
- [ ] Btrfs with snapshots
- [ ] Multi-disk configurations
- [ ] COSMIC Desktop mode
- [ ] Home-manager integration
- [ ] GitHub Actions CI/CD

## Credits

This project is heavily inspired by [Tonarchy](https://github.com/tonybanters/tonarchy) by @tonybanters, 
an excellent zero-dependency Arch Linux installer with a clean TUI. We've adapted its opinionated 
philosophy and user-friendly approach to NixOS.

Key inspirations from Tonarchy:
- Opinionated installation modes (Beginner, Minimal, Advanced)
- Keyboard shortcuts scheme (Super key bindings)
- TUI installer design with fzf integration
- Pre-configured Firefox with privacy extensions
- Zero-to-hero philosophy with sensible defaults

Built on [NixOS](https://nixos.org/) - the purely functional Linux distribution.

## Differences from Tonarchy

While inspired by Tonarchy, this project has some key differences:

| Feature | Tonarchy (Arch) | NixOS Custom ISO |
|---------|-----------------|------------------|
| **Base Distribution** | Arch Linux | NixOS |
| **Installer Language** | C (~1500 lines) | Bash + Nix |
| **Configuration** | Imperative | Declarative (Nix) |
| **Beginner Desktop** | XFCE (getty autologin) | XFCE (LightDM) |
| **Minimal Mode** | OXWM (Rust WM) | Terminal-only |
| **Advanced Mode** | Wayland (Niri) | Hyprland |
| **Package Management** | pacman | Nix/Flakes |
| **Reproducibility** | Manual | Built-in (Nix) |
| **Rollbacks** | Manual/snapshots | Built-in (generations) |

Both projects share the same philosophy: make Linux accessible with opinionated, 
well-configured defaults while teaching best practices.

## License

MIT License - See [LICENSE](LICENSE) for details.
