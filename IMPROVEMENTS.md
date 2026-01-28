# Improvements Summary - Tonarchy Alignment

This document outlines the improvements made to align the NixOS Custom ISO with Tonarchy's philosophy and features.

## Completed Improvements (2026-01-23)

### ✅ High Priority Items

#### 1. Firefox Extensions
**Status:** ✅ Complete

Added Firefox with pre-installed extensions to all desktop profiles:
- **uBlock Origin** - Ad blocker for privacy and security
- **Dark Reader** - Dark mode for all websites

Implementation:
- Used Firefox policies to force-install extensions
- Applied to beginner profile (XFCE)
- Applied to Hyprland profile
- Applied to target system modules

Files modified:
- `profiles/beginner.nix`
- `profiles/hyprland.nix`
- `modules/desktop/xfce.nix`
- `modules/desktop/hyprland.nix`

#### 2. XFCE Keybindings
**Status:** ✅ Complete

Implemented Tonarchy-inspired keybindings for XFCE:

**Application Shortcuts:**
- `Super + Return` → Launch Alacritty terminal
- `Super + D` → Launch Rofi app launcher
- `Super + E` → Open Thunar file manager
- `Print` → Screenshot tool

**Window Management:**
- `Super + Q` → Close window
- `Super + F` → Fullscreen toggle
- `Super + Shift + F` → Maximize window
- `Super + J` → Cycle through windows
- `Super + K` → Cycle windows (reverse)

**Window Tiling:**
- `Super + Left` → Tile window left
- `Super + Right` → Tile window right
- `Super + Up` → Tile window up
- `Super + Down` → Tile window down

**Workspace Management:**
- `Super + 1-9` → Switch to workspace 1-9
- `Super + Shift + 1-9` → Move window to workspace 1-9
- `Super + Tab` → Next workspace
- `Super + Shift + Tab` → Previous workspace

Files modified:
- `profiles/beginner.nix` - Added XFCE keyboard shortcuts XML
- `modules/desktop/xfce.nix` - Added XFCE keyboard shortcuts XML

#### 3. EFI Partition Size
**Status:** ✅ Complete

Changed from: **512MB** → **1GB** (matching Tonarchy)

Reasoning: 1GB provides more headroom for:
- Multiple kernel versions
- Fallback kernels
- Bootloader updates
- Future proofing

Files modified:
- `installer/install.sh` - Updated partition_disk_uefi() function
- `README.md` - Updated disk layout documentation

### ✅ Medium Priority Items

#### 4. Makefile
**Status:** ✅ Complete

Created comprehensive Makefile with targets:

**Build Targets:**
- `make build-beginner` - Build XFCE ISO
- `make build-minimal` - Build minimal ISO
- `make build-hyprland` - Build Hyprland ISO
- `make build-all` - Build all ISOs

**Test Targets:**
- `make test-beginner` - Test beginner ISO in QEMU
- `make test-minimal` - Test minimal ISO in QEMU
- `make test-hyprland` - Test Hyprland ISO in QEMU

**Utility Targets:**
- `make clean` - Remove build artifacts
- `make dev` - Enter development shell
- `make check` - Check flake validity
- `make update` - Update flake inputs
- `make info` - Show flake information
- `make write-usb` - Write ISO to USB drive (interactive)

Files created:
- `Makefile`

#### 5. Custom Logo/Branding
**Status:** ✅ Complete

Created custom ASCII art logo matching Tonarchy's style:

```
   ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗
   ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝
   ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗
   ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║
   ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║
   ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
   
   Custom Installer - Inspired by Tonarchy
   Zero to Hero with Opinionated Defaults
```

Files created:
- `logo.txt`

### ✅ Low Priority Items

#### 6. Wallpapers Directory
**Status:** ✅ Complete

Created wallpapers directory structure with documentation:
- Directory: `wallpapers/`
- README explaining how to add custom wallpapers
- .gitkeep to preserve directory in git
- Documentation on setting default wallpapers per profile

Files created:
- `wallpapers/README.md`
- `wallpapers/.gitkeep`

### ✅ Bonus Improvements

#### 7. GitHub Actions CI/CD
**Status:** ✅ Complete

Created automated workflows:

**build-iso.yml:**
- Builds all three ISOs on push/PR
- Uploads artifacts for 30 days
- Automatically attaches ISOs to releases
- Uses Cachix for build caching

**check.yml:**
- Validates flake on every push/PR
- Runs `nix flake check`
- Shows flake structure

Files created:
- `.github/workflows/build-iso.yml`
- `.github/workflows/check.yml`

#### 8. Documentation Updates
**Status:** ✅ Complete

Enhanced documentation:
- Updated README with new features
- Added Makefile section to README
- Updated disk layout documentation
- Added credits section comparing with Tonarchy
- Created detailed comparison table

Files modified:
- `README.md` - Major updates throughout

Files created:
- `CHANGELOG.md` - Version history tracking
- `TODO.md` - Future improvements tracking
- `IMPROVEMENTS.md` - This file

#### 9. .gitignore Updates
**Status:** ✅ Complete

Added:
- QEMU test disk files (*.qcow2)
- Build logs

Files modified:
- `.gitignore`

## Feature Comparison: Tonarchy vs NixOS Custom ISO

| Feature | Tonarchy | NixOS Custom ISO | Status |
|---------|----------|------------------|--------|
| **Firefox Extensions** | uBlock Origin, Dark Reader | uBlock Origin, Dark Reader | ✅ Match |
| **EFI Partition** | 1GB | 1GB | ✅ Match |
| **Keybindings** | Super-key shortcuts | Super-key shortcuts | ✅ Match |
| **TUI Installer** | Custom C code | Bash script | ✅ Different tech, same UX |
| **fzf Integration** | Yes | Yes | ✅ Match |
| **Beginner Desktop** | XFCE (getty) | XFCE (LightDM) | ⚠️ Different login |
| **Minimal Mode** | OXWM | Terminal-only | ⚠️ Different approach |
| **Wayland Mode** | Niri | Hyprland | ⚠️ Different compositor |
| **Build System** | Makefile + C | Makefile + Nix | ✅ Both have Makefile |
| **Disk Encryption** | Planned | Planned | ⚠️ Both TODO |

## What's Different (Intentional)

Some differences are intentional due to NixOS vs Arch:

1. **Display Manager:** LightDM vs getty - NixOS convention
2. **Minimal WM:** No OXWM equivalent - terminal-only is more NixOS-like
3. **Wayland Compositor:** Hyprland vs Niri - Hyprland has better NixOS support
4. **Configuration Language:** Nix vs manual config - declarative vs imperative
5. **Package Management:** Flakes vs pacman - functional vs imperative

## Future Work

See `TODO.md` for planned improvements:
- LUKS encryption support
- Btrfs with snapshots
- Home-manager integration
- Custom dotfiles deployment
- Additional desktop environments (COSMIC, etc.)

## Testing Checklist

Before release, test:
- [ ] All three ISOs build successfully
- [ ] Firefox extensions are pre-installed
- [ ] XFCE keybindings work correctly
- [ ] EFI partition is 1GB
- [ ] Installer runs successfully in QEMU
- [ ] BIOS boot works
- [ ] UEFI boot works
- [ ] Auto-login works in beginner mode
- [ ] Network connectivity works
- [ ] All Makefile targets work

## Build Commands Quick Reference

```bash
# Build all ISOs
make build-all

# Test an ISO
make test-beginner

# Clean up
make clean

# Enter dev shell
make dev

# Check flake
make check
```

## Conclusion

All critical improvements from Tonarchy have been successfully implemented. 
The NixOS Custom ISO now provides a similar opinionated, user-friendly experience 
while leveraging NixOS's declarative configuration and reproducibility benefits.

The project maintains Tonarchy's "zero to hero" philosophy while adapting it to 
the NixOS ecosystem and conventions.
