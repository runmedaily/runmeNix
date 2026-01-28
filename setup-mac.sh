#!/usr/bin/env bash
#
# Setup script for macOS users
# This script helps Mac users get started with testing the NixOS Custom ISO
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║            NixOS Custom ISO - Mac Setup Helper                 ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if Nix is installed
echo -e "${BLUE}[1/5]${NC} Checking for Nix installation..."
if ! command -v nix &> /dev/null; then
    echo -e "${RED}✗${NC} Nix is not installed!"
    echo ""
    echo "Install Nix with:"
    echo "  sh <(curl -L https://nixos.org/nix/install)"
    echo ""
    echo "Or for multi-user install (recommended):"
    echo "  sh <(curl -L https://nixos.org/nix/install) --daemon"
    exit 1
else
    NIX_VERSION=$(nix --version)
    echo -e "${GREEN}✓${NC} Nix is installed: $NIX_VERSION"
fi

# Check if flakes are enabled
echo -e "${BLUE}[2/5]${NC} Checking for flakes support..."
if nix eval --expr '1 + 1' &> /dev/null; then
    echo -e "${GREEN}✓${NC} Flakes are enabled"
else
    echo -e "${YELLOW}!${NC} Flakes need to be enabled"
    echo ""
    echo "Add this to ~/.config/nix/nix.conf:"
    echo "  experimental-features = nix-command flakes"
    echo ""
    read -p "Would you like me to enable flakes now? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        echo -e "${GREEN}✓${NC} Flakes enabled! You may need to restart your terminal."
    fi
fi

# Check disk space
echo -e "${BLUE}[3/5]${NC} Checking disk space..."
AVAILABLE_GB=$(df -Pk . | awk 'NR==2 {print int($4/1024/1024)}')
echo "Available space: ${AVAILABLE_GB}GB"
if [ "$AVAILABLE_GB" -lt 10 ]; then
    echo -e "${RED}✗${NC} Warning: Less than 10GB free space"
    echo "  Building ISOs requires ~10GB of disk space"
    echo "  Consider freeing up space first"
else
    echo -e "${GREEN}✓${NC} Sufficient disk space available"
fi

# Ask about virtualization preference
echo -e "${BLUE}[4/5]${NC} Choose your testing method..."
echo ""
echo "How would you like to test the ISO?"
echo ""
echo "  1) UTM (Recommended) - Free, Mac-native virtualization"
echo "  2) QEMU - Command-line virtualization (requires Homebrew)"
echo "  3) VirtualBox - Popular VM software"
echo "  4) Skip - I'll choose later"
echo ""
read -p "Enter choice [1-4]: " -n 1 -r CHOICE
echo ""

case "$CHOICE" in
    1)
        echo -e "${BLUE}UTM Selected${NC}"
        echo ""
        echo "Install UTM:"
        echo "  1. Download from Mac App Store (search 'UTM Virtual Machines')"
        echo "  2. Or install via Homebrew: brew install --cask utm"
        echo "  3. Or download from: https://mac.getutm.app/"
        echo ""
        echo "After installing UTM, see: TESTING-ON-MAC.md"
        echo ""
        if command -v brew &> /dev/null; then
            read -p "Install UTM via Homebrew now? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install --cask utm
                echo -e "${GREEN}✓${NC} UTM installed!"
            fi
        fi
        ;;
    2)
        echo -e "${BLUE}QEMU Selected${NC}"
        echo ""
        if command -v brew &> /dev/null; then
            if ! command -v qemu-system-x86_64 &> /dev/null; then
                read -p "Install QEMU via Homebrew now? [y/N]: " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    brew install qemu
                    echo -e "${GREEN}✓${NC} QEMU installed!"
                    echo "You can now use: make test-beginner"
                fi
            else
                echo -e "${GREEN}✓${NC} QEMU is already installed"
            fi
        else
            echo "Install Homebrew first: https://brew.sh/"
            echo "Then run: brew install qemu"
        fi
        ;;
    3)
        echo -e "${BLUE}VirtualBox Selected${NC}"
        echo ""
        if command -v brew &> /dev/null; then
            if ! command -v VBoxManage &> /dev/null; then
                read -p "Install VirtualBox via Homebrew now? [y/N]: " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    brew install --cask virtualbox
                    echo -e "${GREEN}✓${NC} VirtualBox installed!"
                fi
            else
                echo -e "${GREEN}✓${NC} VirtualBox is already installed"
            fi
        else
            echo "Download from: https://www.virtualbox.org/wiki/Downloads"
        fi
        ;;
    4)
        echo "Skipping virtualization setup"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac

# Summary
echo ""
echo -e "${BLUE}[5/5]${NC} Setup complete!"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo ""
echo "  1. Build an ISO:"
echo "     ${CYAN}make build-beginner${NC}"
echo ""
echo "  2. Test it:"
if [ "$CHOICE" = "1" ]; then
    echo "     ${CYAN}See TESTING-ON-MAC.md for UTM instructions${NC}"
elif [ "$CHOICE" = "2" ]; then
    echo "     ${CYAN}make test-beginner${NC}"
else
    echo "     ${CYAN}See TESTING-ON-MAC.md for instructions${NC}"
fi
echo ""
echo "  3. Read the docs:"
echo "     ${CYAN}cat README.md${NC}"
echo "     ${CYAN}cat QUICKSTART.md${NC}"
echo "     ${CYAN}cat TESTING-ON-MAC.md${NC}"
echo ""
echo -e "${YELLOW}Tip:${NC} The first build will take 15-30 minutes and download ~2GB"
echo ""
