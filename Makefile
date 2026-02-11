.PHONY: help build-beginner build-minimal build-hyprland build-all test clean

# Default target
help:
	@echo "NixOS Custom ISO Builder - Inspired by Tonarchy"
	@echo ""
	@echo "Available targets:"
	@echo "  make build-beginner    - Build beginner (XFCE) ISO"
	@echo "  make build-minimal     - Build minimal (terminal-only) ISO"
	@echo "  make build-hyprland    - Build Hyprland (Wayland) ISO"
	@echo "  make build-all         - Build all ISOs"
	@echo "  make test-beginner     - Test beginner ISO in QEMU"
	@echo "  make test-minimal      - Test minimal ISO in QEMU"
	@echo "  make test-hyprland     - Test Hyprland ISO in QEMU"
	@echo "  make clean             - Remove build artifacts"
	@echo "  make dev               - Enter development shell"
	@echo ""
ifeq ($(UNAME_S),Darwin)
	@echo "macOS Detected:"
	@echo "  - QEMU tests require: brew install qemu"
	@echo "  - Or use UTM (recommended): See TESTING-ON-MAC.md"
	@echo ""
endif

# Build targets
build-beginner:
	@echo "Building beginner (XFCE) ISO..."
	nix build .#nixosConfigurations.iso-beginner.config.system.build.isoImage
	@echo "✓ Beginner ISO built successfully!"
	@echo "  Location: result/iso/"

build-minimal:
	@echo "Building minimal (terminal-only) ISO..."
	nix build .#nixosConfigurations.iso-minimal.config.system.build.isoImage
	@echo "✓ Minimal ISO built successfully!"
	@echo "  Location: result/iso/"

build-hyprland:
	@echo "Building Hyprland (Wayland) ISO..."
	nix build .#nixosConfigurations.iso-hyprland.config.system.build.isoImage
	@echo "✓ Hyprland ISO built successfully!"
	@echo "  Location: result/iso/"

build-all: build-beginner build-minimal build-hyprland
	@echo "✓ All ISOs built successfully!"

# Detect OS for QEMU settings
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	QEMU_ACCEL =
	QEMU_CPU = -cpu max
	QEMU_DISPLAY = -display cocoa
else
	QEMU_ACCEL = -enable-kvm
	QEMU_CPU = -cpu host
	QEMU_DISPLAY =
endif

# Test targets (QEMU)
test-beginner: test-disk.qcow2
	@if [ ! -d "result" ]; then \
		echo "Error: No ISO found. Run 'make build-beginner' first."; \
		exit 1; \
	fi
	@if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then \
		echo "Error: QEMU not found!"; \
		echo ""; \
		echo "On macOS, install with:"; \
		echo "  brew install qemu"; \
		echo ""; \
		echo "Or use UTM (recommended): See TESTING-ON-MAC.md"; \
		exit 1; \
	fi
	@echo "Testing beginner ISO in QEMU..."
	@echo "Tips:"
	@echo "  - Press Ctrl+Alt+G to release mouse"
	@echo "  - Press Ctrl+Alt+F to toggle fullscreen"
ifeq ($(UNAME_S),Darwin)
	@echo "  - Press Cmd+Q to quit"
endif
	@echo ""
	qemu-system-x86_64 \
		$(QEMU_ACCEL) \
		-m 4G \
		-smp 2 \
		$(QEMU_CPU) \
		-boot once=d \
		-cdrom result/iso/nixos-beginner-*.iso \
		-drive file=test-disk.qcow2,if=virtio,format=qcow2 \
		-net nic -net user \
		$(QEMU_DISPLAY)

test-minimal: test-disk.qcow2
	@if [ ! -d "result" ]; then \
		echo "Error: No ISO found. Run 'make build-minimal' first."; \
		exit 1; \
	fi
	@if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then \
		echo "Error: QEMU not found! Install with: brew install qemu"; \
		exit 1; \
	fi
	@echo "Testing minimal ISO in QEMU..."
	qemu-system-x86_64 \
		$(QEMU_ACCEL) \
		-m 8G \
		-smp 2 \
		$(QEMU_CPU) \
		-boot once=d \
		-cdrom result/iso/nixos-minimal-*.iso \
		-drive file=test-disk.qcow2,if=virtio,format=qcow2 \
		-net nic -net user \
		$(QEMU_DISPLAY)

test-hyprland: test-disk.qcow2
	@if [ ! -d "result" ]; then \
		echo "Error: No ISO found. Run 'make build-hyprland' first."; \
		exit 1; \
	fi
	@if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then \
		echo "Error: QEMU not found! Install with: brew install qemu"; \
		exit 1; \
	fi
	@echo "Testing Hyprland ISO in QEMU..."
	qemu-system-x86_64 \
		$(QEMU_ACCEL) \
		-m 4G \
		-smp 2 \
		$(QEMU_CPU) \
		-boot once=d \
		-cdrom result/iso/nixos-hyprland-*.iso \
		-drive file=test-disk.qcow2,if=virtio,format=qcow2 \
		-net nic -net user \
		-vga virtio \
		$(QEMU_DISPLAY)

# Create test disk if it doesn't exist
test-disk.qcow2:
	@echo "Creating test virtual disk (20GB)..."
	qemu-img create -f qcow2 test-disk.qcow2 20G

# Clean up
clean:
	@echo "Cleaning build artifacts..."
	rm -rf result
	rm -f test-disk.qcow2
	@echo "✓ Clean complete"

# Development shell
dev:
	@echo "Entering development shell..."
	nix develop

# Format nix files
fmt:
	@echo "Formatting Nix files..."
	fd -e nix -x nixpkgs-fmt

# Check flake
check:
	@echo "Checking flake..."
	nix flake check

# Update flake inputs
update:
	@echo "Updating flake inputs..."
	nix flake update

# Show flake info
info:
	@echo "Flake info:"
	nix flake show

# Write ISO to USB (dangerous - use with caution!)
write-usb:
	@echo "Available USB devices:"
	@lsblk -d -o NAME,SIZE,MODEL | grep -E "sd[a-z]"
	@echo ""
	@echo "⚠️  WARNING: This will ERASE ALL DATA on the selected device!"
	@read -p "Enter device (e.g., sdb): " device; \
	if [ -z "$$device" ]; then \
		echo "Cancelled."; \
		exit 1; \
	fi; \
	read -p "Write to /dev/$$device? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		sudo dd if=result/iso/*.iso of=/dev/$$device bs=4M status=progress oflag=sync; \
		echo "✓ ISO written to /dev/$$device"; \
	else \
		echo "Cancelled."; \
	fi
