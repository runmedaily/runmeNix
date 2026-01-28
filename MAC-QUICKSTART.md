# Mac Quick Start Guide

## TL;DR - Fastest Path to Testing

```bash
# 1. Run the Mac setup helper
./setup-mac.sh

# 2. Build the beginner ISO (15-30 minutes)
make build-beginner

# 3. Install UTM from Mac App Store
# Search: "UTM Virtual Machines"

# 4. Create VM in UTM:
#    - Click "Create a New Virtual Machine"
#    - Choose "Emulate"
#    - Select "Linux"
#    - Boot ISO: result/iso/nixos-beginner-*.iso
#    - Memory: 4GB
#    - Storage: 20GB

# 5. Start the VM and test!
```

## What You'll See

When the VM boots, you'll get:
- XFCE desktop (auto-login as "nixos")
- Firefox with uBlock Origin & Dark Reader
- Tonarchy-style keybindings

## Testing Checklist

Once the VM is running:

✅ **Test Keybindings:**
- Press `Super + Return` → Terminal opens
- Press `Super + D` → Rofi launcher appears
- Press `Super + E` → Thunar file manager opens
- Press `Super + Q` → Close window

✅ **Test Firefox:**
- Open Firefox
- Go to About Add-ons
- Verify uBlock Origin and Dark Reader are installed

✅ **Test Installer:**
```bash
sudo /etc/nixos-custom/install.sh
```
- Navigate through the TUI
- (You can cancel before actual installation)

## Common Mac Issues

### "Nix not found"
```bash
# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Restart terminal
```

### "Flakes not enabled"
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### "Not enough disk space"
You need ~10GB free. Check with:
```bash
df -h .
```

### "QEMU not found"
```bash
# Option 1: Install QEMU (for make test commands)
brew install qemu

# Option 2: Use UTM instead (recommended)
# Download from Mac App Store
```

### "Build is taking forever"
- First build takes 15-30 minutes (normal)
- Downloads ~2GB of packages
- Subsequent builds are much faster

## File Locations

After building, find your ISO:
```bash
ls -lh result/iso/
# Example: nixos-beginner-dev.iso
```

Full path:
```
/Users/rumen.d/Downloads/nixos-custom-iso/result/iso/
```

## UTM Settings Cheat Sheet

**Recommended VM Configuration:**
- **System:** Emulate (x86_64)
- **OS:** Linux
- **Memory:** 4096 MB (4GB)
- **CPU:** 2-4 cores
- **Storage:** 20 GB
- **Boot:** CD/DVD with your ISO

**After Installation:**
- Remove ISO from CD drive
- Reboot to test installed system

## Next Steps

1. ✅ Test beginner ISO in UTM
2. 📦 Build other profiles:
   ```bash
   make build-minimal
   make build-hyprland
   ```
3. 💾 Create bootable USB for real hardware
4. 🚀 Deploy on actual computer

## Need More Help?

- 📖 **Full Mac guide:** [TESTING-ON-MAC.md](TESTING-ON-MAC.md)
- 📖 **General guide:** [README.md](README.md)
- 📖 **Quick reference:** [QUICKSTART.md](QUICKSTART.md)
- 💬 **Issues:** Open a GitHub issue

## Benchmarks (Mac)

**Build Times (approximate):**
- M1/M2/M3 Mac: 15-25 minutes
- Intel Mac: 20-35 minutes

**ISO Sizes (approximate):**
- Beginner: ~1.5 GB
- Minimal: ~800 MB
- Hyprland: ~1.8 GB

**VM Performance in UTM:**
- Emulation mode: Slower but compatible
- Good enough for testing
- For production use, test on real hardware

---

**You're all set! 🎉**

Run `./setup-mac.sh` to get started!
