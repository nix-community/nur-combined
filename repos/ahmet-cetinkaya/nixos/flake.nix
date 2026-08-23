{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Stable nixpkgs channel used for fonts.packages in modules/core/fonts.nix
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nur.url = "github:nix-community/NUR";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pkgs
    zen-browser.url = "github:youwen5/zen-browser-flake";
    whph.url = "github:ahmet-cetinkaya/whph?dir=packaging/nix";
    antigravity-nix = {
      #url = "github:jacopone/antigravity-nix/v1.20.6-5891862175809536";
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CachyOS
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
    cachyos-settings-nix = {
      url = "github:Daaboulex/cachyos-settings-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-flatpak,
    cachyos-settings-nix,
    ...
  } @ inputs: let
    # mkHost: Build a NixOS system configuration.
    # Conditionally includes Home Manager only if hmUsers is non-empty.
    mkHost = {
      name,
      system,
      hmUsers ? {},
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [
                (import ./pkgs)
                inputs.nur.overlays.default
                inputs.antigravity-nix.overlays.default
                inputs.nix-cachyos-kernel.overlays.pinned
              ];
            }
            nix-flatpak.nixosModules.nix-flatpak
            cachyos-settings-nix.nixosModules.default
            ./hosts/${name}/default.nix
          ]
          ++ nixpkgs.lib.optionals (hmUsers != {}) [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                # Use system nixpkgs for Home Manager packages instead of separate evaluation
                useGlobalPkgs = true;
                # Install user packages through Home Manager's user profile.
                useUserPackages = true;
                users = hmUsers;
                extraSpecialArgs = {inherit inputs;};
                # Backup existing files with .hm-backup extension before Home Manager overwrites
                backupFileExtension = "hm-backup";
              };
            }
          ];
      };
  in {
    nixosConfigurations.karakiz = mkHost {
      name = "karakiz";
      system = "x86_64-linux";
      hmUsers.ac = import ./home/ac/default.nix;
    };
  };
}
