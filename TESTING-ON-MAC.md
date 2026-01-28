# Testing NixOS Custom ISO on Mac

## Method 1: UTM (Recommended for Mac)

UTM is a free, easy-to-use virtualization app for Mac that works on both Intel and Apple Silicon.

### Step 1: Install UTM

```bash
# Option A: Download from App Store (easiest)
# Search for "UTM Virtual Machines" in the Mac App Store

# Option B: Install via Homebrew
brew install --cask utm
```

Or download directly: https://mac.getutm.app/

### Step 2: Build Your ISO

```bash
cd /Users/rumen.d/Downloads/nixos-custom-iso

# Build the beginner ISO (this will take 15-30 minutes)
nix build .#nixosConfigurations.iso-beginner.config.system.build.isoImage

# Find your ISO
ls result/iso/*.iso
```

### Step 3: Create a VM in UTM

1. **Open UTM** and click "Create a New Virtual Machine"

2. **Choose "Emulate"** (not Virtualize)
   - This ensures compatibility across all Macs

3. **Select "Linux"** as the operating system

4. **Configure the VM:**
   - **Boot ISO Image:** Browse to `result/iso/nixos-beginner-*.iso`
   - **Memory:** 4096 MB (4GB) minimum, 8192 MB (8GB) recommended
   - **CPU Cores:** 2-4 cores
   - **Storage:** 20 GB minimum

5. **Click "Save"**

### Step 4: Configure Boot Order (Important!)

1. **Select your new VM** in UTM (don't start it yet)
2. **Click the "Edit" button** (looks like a pencil)
3. **Go to "Drives"** section
4. **Make sure the CD/DVD drive with the ISO is listed first**
5. **Click "Save"**

### Step 5: Start the VM

1. **Click the Play button** to start the VM
2. **Wait for NixOS to boot** (1-2 minutes)
3. **You should see the XFCE desktop** with auto-login as user "nixos"

### Step 6: Test the Features

Once booted into the live environment:

#### Test Firefox Extensions
```bash
# Open Firefox from the launcher or:
firefox &
```
- Check: **About Addons** → Should see uBlock Origin and Dark Reader

#### Test Keybindings
- `Super + Return` → Should open Alacritty terminal
- `Super + D` → Should open Rofi launcher
- `Super + E` → Should open Thunar file manager
- `Super + Q` → Should close active window

#### Test the Installer
```bash
# Open terminal (Super + Return) and run:
sudo /etc/nixos-custom/install.sh
```
- Navigate through the TUI installer
- Select installation profile
- (You can cancel before actual installation)

### Step 7: Optional - Install to Virtual Disk

If you want to test the full installation:

1. **Run the installer:**
   ```bash
   sudo /etc/nixos-custom/install.sh
   ```

2. **Follow the prompts:**
   - Select profile (Beginner recommended)
   - Select disk (/dev/vda or /dev/sda)
   - Choose timezone
   - Choose keyboard layout
   - Set hostname and username
   - Confirm installation

3. **After installation:**
   - Shut down the VM
   - Remove the ISO from the CD drive in UTM settings
   - Restart to boot into the installed system

### UTM Tips

**Better Performance (Apple Silicon only):**
If you have an M1/M2/M3 Mac, you can use "Virtualize" instead of "Emulate" for better performance, but you'll need an ARM64 ISO (not covered in this guide).

**Clipboard Sharing:**
- Install SPICE tools in the VM for clipboard sharing
- Or use SSH to connect to the VM

**Screen Resolution:**
- The VM may start with low resolution
- XFCE should auto-adjust, or manually change in Display Settings

**Networking:**
- UTM provides NAT networking by default
- The VM should have internet access automatically

---

## Method 2: QEMU via Homebrew (For Makefile Support)

If you want to use the `make test-*` commands from the Makefile:

### Install QEMU

```bash
# Install QEMU
brew install qemu

# Verify installation
qemu-system-x86_64 --version
```

### Update Makefile for Mac

The current Makefile assumes Linux. You'll need to modify the test targets:

```bash
# Test beginner ISO
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -boot d \
  -cdrom result/iso/nixos-beginner-*.iso \
  -drive file=test-disk.qcow2,if=virtio,format=qcow2 \
  -net nic -net user \
  -display cocoa
```

**Note:** Remove `-enable-kvm` (not available on Mac) and use `-display cocoa` for native Mac window.

### Create Test Disk

```bash
qemu-img create -f qcow2 test-disk.qcow2 20G
```

### Run Test

```bash
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -boot d \
  -cdrom result/iso/nixos-beginner-*.iso \
  -drive file=test-disk.qcow2,if=virtio,format=qcow2 \
  -net nic -net user \
  -display cocoa
```

**QEMU Shortcuts:**
- `Ctrl + Alt + G` - Release mouse
- `Ctrl + Alt + F` - Fullscreen
- `Ctrl + Q` - Quit (in terminal)

---

## Method 3: VirtualBox

### Install VirtualBox

```bash
brew install --cask virtualbox
```

Or download from: https://www.virtualbox.org/wiki/Downloads

### Create VM

1. **Click "New"** in VirtualBox
2. **Name:** NixOS Custom ISO
3. **Type:** Linux
4. **Version:** Linux 2.6 / 3.x / 4.x (64-bit)
5. **Memory:** 4096 MB
6. **Hard Disk:** Create virtual hard disk (20GB, VDI, Dynamically allocated)
7. **Click "Create"**

### Configure VM

1. **Select the VM** → Click "Settings"
2. **System:**
   - Enable EFI (if testing UEFI boot)
   - Processor: 2+ CPUs
3. **Storage:**
   - Click the CD icon under "Controller: IDE"
   - Click the CD icon → "Choose a disk file"
   - Select your `result/iso/nixos-beginner-*.iso`
4. **Click "OK"**

### Start VM

1. **Click "Start"**
2. **Wait for boot**
3. **Test features** as described above

---

## Quick Comparison

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **UTM** | Free, Mac-native, easy GUI | Slower emulation | Most Mac users |
| **QEMU** | Powerful, scriptable | Command-line only | Advanced users |
| **VirtualBox** | Familiar, GUI | Oracle software, slower on M-series | Those who know VirtualBox |

---

## Recommended Testing Workflow

1. **Build ISO:** `nix build .#nixosConfigurations.iso-beginner.config.system.build.isoImage`
2. **Use UTM** for quick testing with GUI
3. **Boot the ISO** and verify:
   - ✅ Desktop loads
   - ✅ Firefox has extensions
   - ✅ Keybindings work
   - ✅ Installer launches
4. **Optional:** Test full installation to virtual disk
5. **Optional:** Test on real hardware via USB

---

## Troubleshooting

### "VM won't boot"
- Check that the ISO is selected as the boot device
- Try disabling EFI and using legacy BIOS mode
- Increase memory to 4GB or more

### "ISO build fails"
- Make sure you have enough disk space (~10GB free)
- Check that Nix is installed: `nix --version`
- Try: `nix flake check` to validate the flake

### "Slow performance in UTM"
- This is normal for x86_64 emulation on Apple Silicon
- Consider using "Virtualize" mode (requires ARM64 ISO)
- Or use real hardware for better performance

### "Can't find ISO file"
The ISO is in: `/Users/rumen.d/Downloads/nixos-custom-iso/result/iso/`

```bash
ls -lh result/iso/
```

---

## Next Steps After Testing

Once you've verified the ISO works:

1. **Test other profiles:**
   ```bash
   make build-minimal
   make build-hyprland
   ```

2. **Create a bootable USB** (for real hardware testing)

3. **Share your ISO** or contribute back to the project

4. **Report any issues** you find

---

**Happy Testing! 🚀**

Need help? Check the main [README.md](README.md) or open an issue.
