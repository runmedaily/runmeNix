{
  description = "Custom NixOS ISO - Opinionated installer inspired by Tonarchy";

  inputs = {
    # NixOS 25.11 stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
      # Helper function to create ISO configurations
      mkIso = { profile, isoName, volumeID ? "NIXOS_CUSTOM" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            # Allow unfree packages (required for firmware)
            { 
              nixpkgs.config.allowUnfree = true;
              # Disable broken ZFS
              boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" ];
            }
            # Base ISO module (minimal for custom installer)
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            # Or use graphical if you want a desktop in live environment:
            # "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma6.nix"
            
            # Core ISO configuration
            ./iso.nix
            
            # Profile-specific configuration
            profile
            
            # ISO naming
            {
              image.fileName = "${isoName}.iso";
              isoImage.volumeID = volumeID;
            }
          ];
        };
    in
    {
      # ISO configurations - build with: nix build .#nixosConfigurations.<name>.config.system.build.isoImage
      nixosConfigurations = {
        # Beginner mode: Full XFCE desktop, batteries included
        iso-beginner = mkIso {
          profile = ./profiles/beginner.nix;
          isoName = "nixos-beginner-${self.shortRev or "dev"}";
          volumeID = "NIXOS_BEGIN";
        };

        # Minimal mode: Lightweight setup for experienced users
        iso-minimal = mkIso {
          profile = ./profiles/minimal.nix;
          isoName = "nixos-minimal-${self.shortRev or "dev"}";
          volumeID = "NIXOS_MIN";
        };

        # Hyprland mode: Modern Wayland tiling
        iso-hyprland = mkIso {
          profile = ./profiles/hyprland.nix;
          isoName = "nixos-hyprland-${self.shortRev or "dev"}";
          volumeID = "NIXOS_HYPR";
        };
      };

      # Target system configurations (what gets installed)
      # These are used by the installer to generate the final system
      nixosConfigurations.target-beginner = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./modules/common.nix
          ./modules/desktop/xfce.nix
        ];
      };

      nixosConfigurations.target-minimal = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./modules/common.nix
          ./modules/desktop/minimal.nix
        ];
      };

      nixosConfigurations.target-hyprland = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./modules/common.nix
          ./modules/desktop/hyprland.nix
        ];
      };

      # Role modules — imported by server local flakes
      nixosModules = {
        home-assistant = import ./modules/roles/home-assistant.nix;
        dual-tailscale = import ./modules/roles/dual-tailscale.nix;
      };

      # Home-manager modules — shared user config (neovim, etc.)
      homeManagerModules = {
        server = import ./modules/shared/server-home.nix;
      };

      # Development shell for working on the ISO
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          gnumake
          nixos-rebuild
          qemu
          # For testing ISOs in VMs
          virt-manager
          # Utilities
          fzf
          dialog
        ];
        shellHook = ''
          echo "NixOS Custom ISO Development Shell"
          echo ""
          echo "Build commands:"
          echo "  nix build .#nixosConfigurations.iso-beginner.config.system.build.isoImage"
          echo "  nix build .#nixosConfigurations.iso-minimal.config.system.build.isoImage"
          echo "  nix build .#nixosConfigurations.iso-hyprland.config.system.build.isoImage"
          echo ""
          echo "Test in QEMU:"
          echo "  qemu-system-x86_64 -enable-kvm -m 4G -cdrom result/iso/*.iso"
        '';
      };

      # Packages - expose the installer script
      packages.${system} = {
        installer = pkgs.writeShellScriptBin "nixos-custom-install" (builtins.readFile ./installer/install.sh);
      };
    };
}
