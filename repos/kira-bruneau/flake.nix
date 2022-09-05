{
  description = "My personal NUR repository";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-checker = {
      url = "gitlab:kira-bruneau/flake-checker";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, flake-checker, nixpkgs }:
    {
      overlays = import ./overlays;
      nixosModules = nixpkgs.lib.mapAttrs (name: value: import value) (import ./nixos/modules);
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };

        paths = flake-checker.lib.partitionToAttrs
          flake-checker.lib.commonFlakePaths
          (flake-checker.lib.walkFlake ./.);

        checker = flake-checker.lib.makeFlakeChecker {
          root = ./.;
          settings = {
            nixpkgs-fmt.paths =
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
                paths.nix);
            prettier.paths = paths.markdown;
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

          inherit (checker) fix;
        };
      }
    );
}
