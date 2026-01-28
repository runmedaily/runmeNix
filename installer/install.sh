#!/usr/bin/env bash
#
# NixOS Custom Installer - TUI installer inspired by Tonarchy
# Provides opinionated installation modes for NixOS
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
MOUNT_POINT="/mnt"
CONFIG_DIR="/etc/nixos"
CUSTOM_DIR="/etc/nixos-custom"

# Installation profile (set during selection)
PROFILE=""
DISK=""
TIMEZONE=""
KEYBOARD=""
TARGET_HOSTNAME=""
USERNAME=""
SWAP_SIZE="4" # GB
ROLE=""

# ============================================================================
# Utility Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

confirm() {
    local prompt="${1:-Continue?}"
    echo -en "${CYAN}${prompt} [y/N]: ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

press_enter() {
    echo -en "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

check_uefi() {
    if [[ -d /sys/firmware/efi/efivars ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# UI Functions
# ============================================================================

show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║     ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗                       ║
    ║     ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝                       ║
    ║     ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗                       ║
    ║     ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║                       ║
    ║     ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║                       ║
    ║     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝                       ║
    ║                                                                   ║
    ║           Custom Installer - Inspired by Tonarchy                 ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# ============================================================================
# Selection Functions (using fzf)
# ============================================================================

select_disk() {
    log_info "Scanning available disks..."

    # Get list of disks (excluding loop, rom, and mounted disks)
    local disks
    disks=$(lsblk -dpno NAME,SIZE,MODEL | grep -E "^/dev/(sd|nvme|vd)" || true)

    if [[ -z "$disks" ]]; then
        log_error "No suitable disks found!"
        exit 1
    fi

    echo -e "\n${BOLD}Available Disks:${NC}"
    echo "$disks"
    echo ""

    if command -v fzf &> /dev/null; then
        DISK=$(echo "$disks" | fzf --prompt="Select disk for installation: " --height=10 | awk '{print $1}') || true
    else
        echo -en "${CYAN}Enter disk path (e.g., /dev/sda): ${NC}"
        read -r DISK
    fi

    if [[ -z "$DISK" ]]; then
        log_error "No disk selected!"
        exit 1
    fi

    # Safety check
    echo -e "\n${RED}${BOLD}WARNING:${NC} This will ${RED}ERASE ALL DATA${NC} on ${BOLD}$DISK${NC}"
    lsblk "$DISK"
    echo ""

    if ! confirm "Are you ABSOLUTELY sure you want to continue?"; then
        log_info "Installation cancelled"
        exit 0
    fi
}

select_timezone() {
    log_info "Selecting timezone..."

    if command -v fzf &> /dev/null; then
        TIMEZONE=$(timedatectl list-timezones 2>/dev/null | fzf --prompt="Select timezone: " --height=20) || true
    else
        echo "Common timezones: America/New_York, America/Los_Angeles, Europe/London, Asia/Tokyo"
        echo -en "${CYAN}Enter timezone: ${NC}"
        read -r TIMEZONE
    fi

    TIMEZONE="${TIMEZONE:-America/Los_Angeles}"
    log_success "Timezone: $TIMEZONE"
}

select_keyboard() {
    log_info "Selecting keyboard layout..."

    local layouts
    layouts=$(localectl list-keymaps 2>/dev/null || echo "us")

    if command -v fzf &> /dev/null && [[ -n "$layouts" ]]; then
        KEYBOARD=$(echo "$layouts" | fzf --prompt="Select keyboard layout: " --height=20 --query="us") || true
    else
        echo -en "${CYAN}Enter keyboard layout [us]: ${NC}"
        read -r KEYBOARD
    fi

    KEYBOARD="${KEYBOARD:-us}"
    log_success "Keyboard: $KEYBOARD"
}

get_user_info() {
    echo ""
    echo -en "${CYAN}Enter hostname [nixos]: ${NC}"
    read -r TARGET_HOSTNAME
    TARGET_HOSTNAME="${TARGET_HOSTNAME:-nixos}"
    
    echo -en "${CYAN}Enter username [user]: ${NC}"
    read -r USERNAME
    USERNAME="${USERNAME:-user}"
    
    echo -en "${CYAN}Enter swap size in GB [4]: ${NC}"
    read -r SWAP_SIZE
    SWAP_SIZE="${SWAP_SIZE:-4}"
    
    log_success "Hostname: $TARGET_HOSTNAME"
    log_success "Username: $USERNAME"
    log_success "Swap: ${SWAP_SIZE}GB"
}

select_role() {
    echo ""
    echo -e "${BOLD}Available Roles:${NC}"
    echo "  1) home-assistant  - Home automation server (Tailscale, SSH, ZSH, Neovim)"
    echo "  2) minimal         - Basic terminal server"
    echo ""

    if command -v fzf &> /dev/null; then
        ROLE=$(echo -e "home-assistant\nminimal" | fzf --prompt="Select role: " --height=5) || true
    else
        echo -en "${CYAN}Select role [home-assistant]: ${NC}"
        read -r ROLE
    fi

    ROLE="${ROLE:-home-assistant}"
    log_success "Role: $ROLE"
}

# ============================================================================
# Partitioning Functions
# ============================================================================

partition_disk_uefi() {
    log_info "Partitioning disk (UEFI mode)..."
    
    # Wipe existing partition table
    wipefs -af "$DISK"
    
    # Create GPT partition table
    parted -s "$DISK" mklabel gpt
    
    # Create EFI partition (1GB - matching Tonarchy)
    parted -s "$DISK" mkpart ESP fat32 1MiB 1025MiB
    parted -s "$DISK" set 1 esp on
    
    # Create swap partition
    local swap_end=$((1025 + SWAP_SIZE * 1024))
    parted -s "$DISK" mkpart primary linux-swap 1025MiB "${swap_end}MiB"
    
    # Create root partition (rest of disk)
    parted -s "$DISK" mkpart primary ext4 "${swap_end}MiB" 100%
    
    # Wait for partitions to appear
    sleep 2
    partprobe "$DISK"
    sleep 1
    
    # Determine partition naming
    local part_prefix=""
    if [[ "$DISK" == *"nvme"* ]] || [[ "$DISK" == *"mmcblk"* ]]; then
        part_prefix="${DISK}p"
    else
        part_prefix="$DISK"
    fi
    
    # Format partitions
    log_info "Formatting partitions..."
    mkfs.fat -F32 "${part_prefix}1"
    mkswap "${part_prefix}2"
    mkfs.ext4 -F "${part_prefix}3"
    
    log_success "Disk partitioned successfully"
}

partition_disk_bios() {
    log_info "Partitioning disk (BIOS mode)..."

    # Wipe existing partition table
    wipefs -af "$DISK"

    # Create GPT partition table with BIOS boot partition
    parted -s "$DISK" mklabel gpt

    # Create BIOS boot partition (1MB for GRUB)
    parted -s "$DISK" mkpart primary 1MiB 2MiB
    parted -s "$DISK" set 1 bios_grub on

    # Create swap partition
    local swap_end=$((2 + SWAP_SIZE * 1024))
    parted -s "$DISK" mkpart primary linux-swap 2MiB "${swap_end}MiB"

    # Create root partition (rest of disk)
    parted -s "$DISK" mkpart primary ext4 "${swap_end}MiB" 100%

    # Wait for partitions
    sleep 2
    partprobe "$DISK"
    sleep 1

    # Determine partition naming
    local part_prefix=""
    if [[ "$DISK" == *"nvme"* ]] || [[ "$DISK" == *"mmcblk"* ]]; then
        part_prefix="${DISK}p"
    else
        part_prefix="$DISK"
    fi

    # Format partitions (part1 is bios_grub, no filesystem)
    log_info "Formatting partitions..."
    mkswap "${part_prefix}2"
    mkfs.ext4 -F "${part_prefix}3"

    log_success "Disk partitioned successfully"
}

mount_partitions_uefi() {
    log_info "Mounting partitions..."
    
    local part_prefix=""
    if [[ "$DISK" == *"nvme"* ]] || [[ "$DISK" == *"mmcblk"* ]]; then
        part_prefix="${DISK}p"
    else
        part_prefix="$DISK"
    fi
    
    mount "${part_prefix}3" "$MOUNT_POINT"
    mkdir -p "$MOUNT_POINT/boot"
    mount "${part_prefix}1" "$MOUNT_POINT/boot"
    swapon "${part_prefix}2"
    
    log_success "Partitions mounted"
}

mount_partitions_bios() {
    log_info "Mounting partitions..."

    local part_prefix=""
    if [[ "$DISK" == *"nvme"* ]] || [[ "$DISK" == *"mmcblk"* ]]; then
        part_prefix="${DISK}p"
    else
        part_prefix="$DISK"
    fi

    mount "${part_prefix}3" "$MOUNT_POINT"
    swapon "${part_prefix}2"

    log_success "Partitions mounted"
}

# ============================================================================
# Configuration Generation
# ============================================================================

generate_flake() {
    log_info "Generating NixOS flake configuration..."

    # Generate hardware configuration
    nixos-generate-config --root "$MOUNT_POINT"

    # Generate flake.nix
    cat > "$MOUNT_POINT$CONFIG_DIR/flake.nix" << EOF
{
  description = "$TARGET_HOSTNAME server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    runmeNix = {
      url = "github:runmedaily/runmeNix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, runmeNix, ... }:
  let
    home-manager = runmeNix.inputs.home-manager;
  in {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./local.nix
        runmeNix.nixosModules.$ROLE
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.$USERNAME = {
            imports = [ runmeNix.homeManagerModules.server ];
            home.stateVersion = "25.11";
          };
        }
      ];
    };
  };
}
EOF

    # Generate local.nix (host-specific)
    cat > "$MOUNT_POINT$CONFIG_DIR/local.nix" << LOCALEOF
{ pkgs, ... }:
{
LOCALEOF

    # Boot loader (conditional)
    if check_uefi; then
        cat >> "$MOUNT_POINT$CONFIG_DIR/local.nix" << LOCALEOF
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
LOCALEOF
    else
        cat >> "$MOUNT_POINT$CONFIG_DIR/local.nix" << LOCALEOF
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "$DISK";
LOCALEOF
    fi

    cat >> "$MOUNT_POINT$CONFIG_DIR/local.nix" << LOCALEOF

  networking.hostName = "$TARGET_HOSTNAME";
  time.timeZone = "$TIMEZONE";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "$KEYBOARD";

  users.users.$USERNAME = {
    isNormalUser = true;
    description = "$USERNAME";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwWB/kUbJoBLlUWEtGjLhUwl0PnMO06Uq9MufQxnNrn nixos-custom-iso"
    ];
  };

  system.stateVersion = "25.11";
}
LOCALEOF

    log_success "Flake configuration generated"
}

# ============================================================================
# Installation
# ============================================================================

run_installation() {
    log_info "Starting NixOS installation..."
    log_info "This may take a while depending on your internet connection..."
    echo ""

    # Copy flake config outside /mnt to avoid Nix assertion bug
    # (flake path under --store mount causes NAR hash mismatch)
    local tmp_flake="/tmp/nixos-flake-config"
    rm -rf "$tmp_flake"
    cp -r "$MOUNT_POINT$CONFIG_DIR" "$tmp_flake"

    # Run nixos-install with flake from temp location
    nixos-install --flake "$tmp_flake#default" --no-root-passwd

    rm -rf "$tmp_flake"
    log_success "Installation complete!"
}

set_user_password() {
    log_info "Setting password for user '$USERNAME'..."
    echo ""
    nixos-enter --root "$MOUNT_POINT" -c "passwd $USERNAME"
}

# ============================================================================
# Main Flow
# ============================================================================

main() {
    check_root

    PROFILE="minimal"

    show_banner
    echo -e "${BOLD}Profile: ${GREEN}$PROFILE${NC}\n"
    
    # Boot mode detection
    if check_uefi; then
        log_info "Detected: UEFI boot mode"
    else
        log_info "Detected: BIOS/Legacy boot mode"
    fi
    echo ""
    
    # Gather information
    select_disk
    select_timezone
    select_keyboard
    get_user_info
    select_role

    # Summary
    show_banner
    echo -e "${BOLD}Installation Summary:${NC}"
    echo "─────────────────────────────────────"
    echo -e "  Profile:   ${GREEN}$PROFILE${NC}"
    echo -e "  Role:      ${GREEN}$ROLE${NC}"
    echo -e "  Disk:      ${YELLOW}$DISK${NC}"
    echo -e "  Timezone:  $TIMEZONE"
    echo -e "  Keyboard:  $KEYBOARD"
    echo -e "  Hostname:  $TARGET_HOSTNAME"
    echo -e "  Username:  $USERNAME"
    echo -e "  Swap:      ${SWAP_SIZE}GB"
    if check_uefi; then
        echo -e "  Boot:      UEFI"
    else
        echo -e "  Boot:      BIOS/Legacy"
    fi
    echo "─────────────────────────────────────"
    echo ""
    
    if ! confirm "Proceed with installation?"; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    # Partition and format
    if check_uefi; then
        partition_disk_uefi
        mount_partitions_uefi
    else
        partition_disk_bios
        mount_partitions_bios
    fi
    
    # Generate flake configuration
    generate_flake
    
    # Run installation
    run_installation
    
    # Set user password
    set_user_password
    
    # Done!
    show_banner
    echo -e "${GREEN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║              Installation Complete! 🎉                            ║"
    echo "║                                                                   ║"
    echo "║   Remove the installation media and reboot to start using        ║"
    echo "║   your new NixOS system.                                         ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    if confirm "Reboot now?"; then
        umount -R "$MOUNT_POINT" 2>/dev/null || true
        swapoff -a 2>/dev/null || true
        eject /dev/sr0 2>/dev/null || eject /dev/cdrom 2>/dev/null || true
        reboot
    fi
}

# Run main
main "$@"
