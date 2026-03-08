{
  home-manager,
  nix-darwin,
  nixpkgs-stable,
  nixpkgs-unstable,
  self,
  ...
}@inputs:
let
  homelab = import ../homelab.nix;
  lib = nixpkgs-unstable.lib;
  nixosSystem =
    {
      system,
      nixosModules ? [ ],
    }:
    let
      unstablePkgs = self.lib.import_nixpkgs system nixpkgs-unstable;
      stablePkgs = self.lib.import_nixpkgs system nixpkgs-stable;
    in
    lib.nixosSystem {
      inherit system;
      pkgs = unstablePkgs;
      specialArgs = {
        inherit
          inputs
          system
          homelab
          stablePkgs
          unstablePkgs
          ;
      };
      modules = nixosModules;
    };
  darwinSystem =
    {
      system,
      darwinModules ? [ ],
    }:
    let
      unstablePkgs = self.lib.import_nixpkgs system nixpkgs-unstable;
      stablePkgs = self.lib.import_nixpkgs system nixpkgs-stable;
    in
    nix-darwin.lib.darwinSystem {
      pkgs = unstablePkgs;
      specialArgs = {
        inherit
          inputs
          system
          homelab
          stablePkgs
          unstablePkgs
          ;
      };
      modules = darwinModules;
    };
  homeConfiguration =
    {
      system,
      homeModules ? [ ],
    }:
    let
      unstablePkgs = self.lib.import_nixpkgs system nixpkgs-unstable;
      stablePkgs = self.lib.import_nixpkgs system nixpkgs-stable;
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = stablePkgs;
      extraSpecialArgs = {
        inherit
          inputs
          system
          homelab
          stablePkgs
          unstablePkgs
          ;
      };
      modules = homeModules;
    };
in
{
  darwinConfigurations = {
    MacBook-Pro = darwinSystem {
      system = "aarch64-darwin";
      darwinModules = [ ./MacBook-Pro/configuration.nix ];
    };
    MacMini-Intel = darwinSystem {
      system = "x86_64-darwin";
      darwinModules = [ ./MacMini-Intel/configuration.nix ];
    };
    MacMini-M1 = darwinSystem {
      system = "aarch64-darwin";
      darwinModules = [ ./MacMini-M1/configuration.nix ];
    };
  };
  homeConfigurations = {
    "deck@steamdeck" = homeConfiguration {
      system = "x86_64-linux";
      homeModules = [
        ./steamdeck/home.nix
      ];
    };
    "droid@debian" = homeConfiguration {
      system = "aarch64-linux";
      homeModules = [
        ./pixel10a/home.nix
      ];
    };
  };
  nixosConfigurations = {
    HP-Envy = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./HP-Envy/configuration.nix ];
    };
    HP-ZBook = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./HP-ZBook/configuration.nix ];
    };
    MacBook-Pro-Nixos = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./MacBook-Pro-Nixos/configuration.nix
      ];
    };
    nas = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./nas/configuration.nix ];
    };
    oracle-cloud-nixos = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./oracle-cloud-nixos/configuration.nix
      ];
    };
    PineBook-Pro = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./PineBook-Pro/configuration.nix
      ];
    };
    Protectli = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./Protectli/configuration.nix ];
    };
    router = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./router/configuration.nix ];
    };
    rpi4b4a = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b4a/configuration.nix ];
    };
    rpi4b8a = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b8a/configuration.nix ];
    };
    rpi4b8b = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b8b/configuration.nix ];
    };
    rpi4b8c = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b8c/configuration.nix ];
    };
    steamdeck-nixos = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [
        ./steamdeck-nixos/configuration.nix
      ];
    };
    Thinkpad = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./Thinkpad/configuration.nix ];
    };
    utm = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./utm/configuration.nix
      ];
    };
    wsl = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [
        ./wsl/configuration.nix
      ];
    };
  };
}
