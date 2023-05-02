{
  inputs = {

    utils.url = "github:numtide/flake-utils";

    #nixpkgs-22-05.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs, unstable, utils }:
  let

    localOverlay = prev: final: {
    };

    pkgsForSystem = system: import nixpkgs {
      overlays = [
        localOverlay
      ];

      inherit system;
      config.allowUnfree = true;
    };
    unstableForSystem = system: import unstable {
      overlays = [
        localOverlay
      ];

      inherit system;
      config.allowUnfree = true;
    };

  in utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system: rec {
    legacyPackages = pkgsForSystem system;
  }) // {

    overlays = import ./overlays;
    overlay = localOverlay;

    /*
    DOT FILES
    */

    homeConfigurations = {
      "pim@lego1" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home-manager/home-machine-lego1.nix) ];
        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          withLinny = true;
          isDesktop = true;
          tmuxPrefix = "a";
          unstable = unstableForSystem "x86_64-linux";
          inherit localOverlay;
        };
      };

      "pim@ojs" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home-manager/home-machine-ojs.nix) ];

        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          withLinny = true;
          isDesktop = true;
          tmuxPrefix = "a";
          unstable = unstableForSystem "x86_64-linux";
          inherit localOverlay;
        };
      };

      "pim@rodin" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home-manager/home-machine-rodin.nix) ];

        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          withLinny = false;
          isDesktop = false;
          tmuxPrefix = "b";
          unstable = unstableForSystem "x86_64-linux";
          inherit localOverlay;
        };
      };
    };

    inherit home-manager;
    inherit (home-manager) packages;

    /*
    MACHINES
    */

    nixosConfigurations.rodin = nixpkgs.lib.nixosSystem {

      modules =
        let
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/rodin/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
      ];
    };

    nixosConfigurations.lego1 = nixpkgs.lib.nixosSystem {

      modules =
        let
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/lego1/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
      ];
    };

    nixosConfigurations.ojs = nixpkgs.lib.nixosSystem {

      modules =
        let
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/ojs/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
      ];
    };

    nixosConfigurations.billquick = nixpkgs.lib.nixosSystem {

      modules =
        let
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/billquick/configuration.nix
          .home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
      ];

    };

  };
}
