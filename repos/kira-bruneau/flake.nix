{
  description = "My personal NUR repository";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    flake-linter = {
      url = "gitlab:kira-bruneau/flake-linter";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, flake-linter, nixpkgs }:
    {
      overlays = import ./overlays;
      nixosModules = builtins.mapAttrs (name: value: import value) (import ./nixos/modules);
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };

        paths = flake-linter.lib.partitionToAttrs
          flake-linter.lib.commonFlakePaths
          (builtins.filter
            (path:
              (builtins.all
                (ignore: !(nixpkgs.lib.hasSuffix ignore path))
                [
                  "gemset.nix"
                  "node-composition.nix"
                  "node-env.nix"
                  "node-packages.nix"
                ]))
            (flake-linter.lib.walkFlake ./.));

        linter = flake-linter.lib.makeFlakeLinter {
          root = ./.;

          settings = {
            markdownlint = {
              paths = paths.markdown;
              extraSettings = {
                default = true;
                MD013 = false;
              };
            };

            nixpkgs-fmt.paths = paths.nix;
          };

          inherit pkgs;
        };

        nurPkgs = import ./pkgs (pkgs // nurPkgs) pkgs;
      in
      rec {
        packages = flake-utils.lib.filterPackages system (flake-utils.lib.flattenTree nurPkgs);

        checks = packages;

        apps = {
          sync = {
            type = "app";
            program = toString (nurPkgs.callPackage ./maintainers/scripts/sync.nix {
              rev = nixpkgs.rev;
            });
          };

          inherit (linter) fix;
        };
      }
    );
}
