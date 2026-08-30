{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-akana.url = "github:nixos/nixpkgs/nixos-26.05";
    # Stable nixpkgs channel used for fonts.packages in modules/core/fonts.nix
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nur.url = "github:nix-community/NUR";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-akana = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-akana";
    };
    nix-dokploy = {
      url = "github:el-kurto/nix-dokploy";
      inputs.nixpkgs.follows = "nixpkgs-akana";
    };
    # pkgs
    zen-browser.url = "github:youwen5/zen-browser-flake";
    whph.url = "github:ahmet-cetinkaya/whph?dir=packaging/nix";
    antigravity-nix = {
      #url = "github:jacopone/antigravity-nix/v1.20.6-5891862175809536";
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    areofyl-fetch.url = "github:areofyl/fetch";
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
      nixpkgsInput ? nixpkgs,
      homeManagerInput ? home-manager,
      overlays ? [],
      extraModules ? [],
      hmUsers ? {},
    }:
      nixpkgsInput.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = overlays;
            }
          ]
          ++ extraModules
          ++ [
            ./hosts/${name}/default.nix
          ]
          ++ nixpkgsInput.lib.optionals (hmUsers != {}) [
            homeManagerInput.nixosModules.home-manager
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
    nixosConfigurations.akana = mkHost {
      name = "akana";
      system = "x86_64-linux";
      nixpkgsInput = inputs.nixpkgs-akana;
      homeManagerInput = inputs.home-manager-akana;
      hmUsers.ac = import ./home/ac/default.nix;
    };

    nixosConfigurations.karakiz = mkHost {
      name = "karakiz";
      system = "x86_64-linux";
      overlays = [
        (import ./pkgs)
        inputs.nur.overlays.default
        inputs.antigravity-nix.overlays.default
        inputs.areofyl-fetch.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
      ];
      extraModules = [
        nix-flatpak.nixosModules.nix-flatpak
        cachyos-settings-nix.nixosModules.default
      ];
      hmUsers.ac = import ./home/ac/default.nix;
    };
  };
}
