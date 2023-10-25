{
  inputs = {

    ## MAIN NIXPKGS
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-gnome-45.url = "github:NixOS/nixpkgs?ref=gnome";

    nixpkgs-inkscape13.url = "github:leiserfg/nixpkgs?ref=staging";

    ## HOME MANAGER
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #home-manager-main.url = "github:nix-community/home-manager";

    ## OTHER
    agenix.url = "github:ryantm/agenix";
    utils.url = "github:numtide/flake-utils";

    nixified-ai = { url = "github:nixified-ai/flake"; };

  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    unstable,
    nixpkgs-inkscape13,
    nixpkgs-gnome-45,
    utils,
    agenix,
    nixified-ai
  }:

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

    nixpkgs-inkscape13ForSystem = system: import nixpkgs-inkscape13 {
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
    gnome45ForSystem = system: import nixpkgs-gnome-45 {
      overlays = [
        localOverlay
      ];

      inherit system;
      config.allowUnfree = true;
      config.allowUnsupportedSystem = true;
      config.allowBroken = true;
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
          inherit localOverlay;
        };
      };

      "pim@rodin" = home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home/pim/home-machine-rodin.nix) ];

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
    };

    inherit home-manager;
    inherit (home-manager) packages;

    /*
    MACHINES
    */

    nixosConfigurations.rodin = nixpkgs.lib.nixosSystem {

      modules =
        let
          system = "x86_64-linux";
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
            _module.args.nixpkgs-inkscape13 = nixpkgs-inkscape13ForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/rodin/configuration.nix
          { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }

#          {
#              imports = [
#                nixified-ai.nixosModules.invokeai
#              ];
#
#              environment.systemPackages = [
#                nixified-ai.packages.${system}.invokeai-nvidia
#              ];
#
#  #            services.invokeai = {
#  #              enable = false;
#  #              host = "0.0.0.0";
#  #              nsfwChecker = false;
#  #              package = nixified-ai.packages.${system}.invokeai-nvidia;
#  #            };
#
#            }


      ];
    };

    nixosConfigurations.lego1 = nixpkgs.lib.nixosSystem {

      modules =
        let
          system = "x86_64-linux";
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
            _module.args.nixpkgs-inkscape13 = nixpkgs-inkscape13ForSystem "x86_64-linux";
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
            _module.args.nixpkgs-inkscape13 = nixpkgs-inkscape13ForSystem "x86_64-linux";
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

    nixosConfigurations.grannyos = nixpkgs.lib.nixosSystem {

      modules =
        let
          system = "x86_64-linux";
          defaults = { pkgs, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/grannyos/configuration.nix

          { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
      ];
    };

    nixosConfigurations.gnome-45 = nixpkgs-gnome-45.lib.nixosSystem {

      pkgs = gnome45ForSystem "x86_64-linux";
      modules =
        let
          system = "x86_64-linux";
          defaults = { gnome45ForSystem, ... }: {
            _module.args.unstable = unstableForSystem "x86_64-linux";
          };
        in [
          defaults
          ./hosts/gnome-45/configuration.nix


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
