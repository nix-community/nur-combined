{
  inputs = {

    utils.url = "github:numtide/flake-utils";

    #nixpkgs-22-05.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    #nixpkgs-23-05.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    #home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgsinkscape13.url = "github:leiserfg/nixpkgs?ref=staging";

    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, home-manager, nixpkgs, unstable, nixpkgsinkscape13, utils, agenix }:

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

    nixpkgsinkscape13ForSystem = system: import nixpkgsinkscape13 {
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
      "pim@adevintamac" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home/pim/home-machine-adevinta.nix) ];
        pkgs = pkgsForSystem "x86_64-darwin";
        extraSpecialArgs = {
          username = "pim.snel";
          homedir = "/Users/pim.snel";
          withLinny = true;
          isDesktop = true;
          tmuxPrefix = "a";
          unstable = unstableForSystem "x86_64-darwin";
          inherit localOverlay;
        };
      };



      "pim@lego1" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home/pim/home-machine-lego1.nix) ];
        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          username = "pim";
          homedir = "/home/pim";
          withLinny = true;
          isDesktop = true;
          tmuxPrefix = "a";
          unstable = unstableForSystem "x86_64-linux";
          inherit localOverlay;
        };
      };

      "pim@ojs" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home/pim/home-machine-ojs.nix) ];

        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          username = "pim";
          homedir = "/home/pim";
          withLinny = true;
          isDesktop = true;
          tmuxPrefix = "a";
          unstable = unstableForSystem "x86_64-linux";
          #old2211 = old2211ForSystem "x86_64-linux";
          inherit localOverlay;
        };
      };

      "pim@rodin" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home/pim/home-machine-rodin.nix) ];

        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          username = "pim";
          homedir = "/home/pim";
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
          system = "x86_64-linux";
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/lego1/configuration.nix
          { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
      ];
    };

    nixosConfigurations.ojs = nixpkgs.lib.nixosSystem {

      modules =
        let
          system = "x86_64-linux";
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
            _module.args.nixpkgsinkscape13 = nixpkgsinkscape13ForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/ojs/configuration.nix
          { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          agenix.nixosModules.default
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
