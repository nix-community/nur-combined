{
  description = "NixOS configuration with flakes";
  inputs = {
    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
      };
    };
  };

  outputs =
    inputs @
    { self
    , futils
    , home-manager
    , nixpkgs
    , nur
    , pre-commit-hooks
    }:
    let
      inherit (futils.lib) eachDefaultSystem;

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
        # Include my secrets
        ./secrets
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
    eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        apps = {
          diff-flake = futils.lib.mkApp { drv = packages.diff-flake; };
        };

        checks = {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;

            hooks = {
              nixpkgs-fmt = {
                enable = true;
              };
            };
          };
        };

        defaultApp = apps.diff-flake;

        devShell = pkgs.mkShell {
          name = "NixOS-config";

          buildInputs = with pkgs; [
            git-crypt
            gitAndTools.pre-commit
            gnupg
            nixpkgs-fmt
          ];

          inherit (self.checks.${system}.pre-commit) shellHook;
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
      overlay = self.overlays.pkgs;

      overlays = import ./overlays // {
        lib = final: prev: { inherit lib; };
        pkgs = final: prev: { ambroisie = import ./pkgs { pkgs = prev; }; };
      };

      nixosConfigurations = lib.mapAttrs buildHost {
        aramis = "x86_64-linux";
        porthos = "x86_64-linux";
      };
    };
}
