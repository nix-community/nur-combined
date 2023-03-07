{
  description = "NixOS configuration with flakes";
  inputs = {
    agenix = {
      type = "github";
      owner = "ryantm";
      repo = "agenix";
      ref = "main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "futils";
      };
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    nur = {
      type = "github";
      owner = "nix-community";
      repo = "NUR";
      ref = "master";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";
      ref = "master";
      inputs = {
        flake-utils.follows = "futils";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs @
    { self
    , agenix
    , futils
    , home-manager
    , nixpkgs
    , nur
    , pre-commit-hooks
    }:
    let
      inherit (self) lib;

      inherit (futils.lib) eachSystem system;

      mySystems = [
        system.aarch64-darwin
        system.aarch64-linux
        system.x86_64-darwin
        system.x86_64-linux
      ];

      eachMySystem = eachSystem mySystems;

    in
    eachMySystem
      (system:
      rec {
        apps = {
          diff-flake = futils.lib.mkApp { drv = packages.diff-flake; };
          default = apps.diff-flake;
        };

        checks = import ./flake/checks.nix inputs system;

        devShells = import ./flake/dev-shells.nix inputs system;

        packages = import ./flake/packages.nix inputs system;

        # Work-around for https://github.com/nix-community/home-manager/issues/3075
        legacyPackages = {
          homeConfigurations = {
            ambroisie = home-manager.lib.homeManagerConfiguration {
              # Work-around for home-manager 
              # * not letting me set `lib` as an extraSpecialArgs
              # * not respecting `nixpkgs.overlays` [1]
              # [1]: https://github.com/nix-community/home-manager/issues/2954
              pkgs = import nixpkgs {
                inherit system;

                overlays = (lib.attrValues self.overlays) ++ [
                  nur.overlay
                ];
              };

              modules = [
                ./home
                {
                  # The basics
                  home.username = "ambroisie";
                  home.homeDirectory = "/home/ambroisie";
                  # Let Home Manager install and manage itself.
                  programs.home-manager.enable = true;
                  # This is a generic linux install
                  targets.genericLinux.enable = true;
                }
              ];

              extraSpecialArgs = {
                # Inject inputs to use them in global registry
                inherit inputs;
              };
            };
          };
        };
      }) // {
      lib = import ./flake/lib.nix inputs;

      overlays = import ./flake/overlays.nix inputs;

      nixosConfigurations = import ./flake/nixos.nix inputs;
    };
}
