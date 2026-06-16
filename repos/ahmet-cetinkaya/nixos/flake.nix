{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      inputs.nixpkgs.follows = "nixpkgs";
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
    system = "x86_64-linux";
  in {
    nixosConfigurations.karakiz = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {
          nixpkgs.hostPlatform = system;
          nixpkgs.overlays = [
            (import ./pkgs)
            inputs.nur.overlays.default
            inputs.antigravity-nix.overlays.default
            inputs.nix-cachyos-kernel.overlays.default
          ];
        }
        nix-flatpak.nixosModules.nix-flatpak
        cachyos-settings-nix.nixosModules.default
        ./hosts/karakiz/default.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.ac = import ./home/ac/default.nix;
            extraSpecialArgs = {inherit inputs;};
            backupFileExtension = "hm-backup";
          };
        }
      ];
    };
  };
}
