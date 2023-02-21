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
      inherit (futils.lib) eachSystem system;

      mySystems = [
        system.aarch64-linux
        system.x86_64-darwin
        system.x86_64-linux
      ];

      eachMySystem = eachSystem mySystems;

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib { inherit inputs; pkgs = nixpkgs; lib = self; };
      });

      defaultModules = [
        ({ ... }: {
          # Let 'nixos-version --json' know about the Git revision
          system.configurationRevision = self.rev or "dirty";
        })
        {
          nixpkgs.overlays = (lib.attrValues self.overlays) ++ [
            nur.overlay
          ];
        }
        # Include generic settings
        ./modules
        # Include bundles of settings
        ./profiles
      ];

      buildHost = name: system: lib.nixosSystem {
        inherit system;
        modules = defaultModules ++ [
          (./. + "/machines/${name}")
        ];
        specialArgs = {
          # Use my extended lib in NixOS configuration
          inherit lib;
          # Inject inputs to use them in global registry
          inherit inputs;
        };
      };
    in
    eachMySystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        apps = {
          diff-flake = futils.lib.mkApp { drv = packages.diff-flake; };
          default = apps.diff-flake;
        };

        checks = {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;

            hooks = {
              nixpkgs-fmt = {
                enable = true;
              };

              shellcheck = {
                enable = true;
              };
            };
          };
        };

        devShells = {
          default = pkgs.mkShell {
            name = "NixOS-config";

            nativeBuildInputs = with pkgs; [
              gitAndTools.pre-commit
              nixpkgs-fmt
            ];

            inherit (self.checks.${system}.pre-commit) shellHook;
          };
        };

        packages =
          let
            inherit (futils.lib) filterPackages flattenTree;
            packages = import ./pkgs { inherit pkgs; };
            flattenedPackages = flattenTree packages;
            finalPackages = filterPackages system flattenedPackages;
          in
          finalPackages;
      }) // {
      overlays = import ./overlays // {
        lib = final: prev: { inherit lib; };
        pkgs = final: prev: {
          ambroisie = prev.recurseIntoAttrs (import ./pkgs { pkgs = prev; });
        };
      };
      homeConfigurations =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            overlays = (lib.attrValues self.overlays) ++ [
              nur.overlay
            ];
          };
        in
        {
          ambroisie = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

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

      nixosConfigurations = lib.mapAttrs buildHost {
        aramis = "x86_64-linux";
        porthos = "x86_64-linux";
      };
    };
}
