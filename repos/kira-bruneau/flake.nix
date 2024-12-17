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

    nix-fast-build.url = "github:Mic92/nix-fast-build";
  };

  outputs =
    {
      flake-utils,
      flake-linter,
      nixpkgs,
      nix-fast-build,
      ...
    }:
    {
      overlays = import ./overlays;
      nixosModules = import ./nixos/modules;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        lib = nixpkgs.lib;

        pkgs = import nixpkgs {
          config = {
            allowUnfreePredicate =
              pkg:
              builtins.elem (builtins.parseDrvName (lib.getName pkg)).name [
                "anytype"
                "anytype-heart"
                "anytype-nmh"
                "clonehero"
                "habitica"
                "habitica-client"
                "virtualparadise"
              ];
          };

          inherit system;
        };

        flake-linter-lib = flake-linter.lib.${system};

        paths = flake-linter-lib.partitionToAttrs flake-linter-lib.commonPaths (
          builtins.filter (
            path:
            (builtins.all (ignore: !(lib.hasSuffix ignore path)) [
              "pkgs/applications/audio/zynaddsubfx/default.nix"
              "pkgs/tools/graphics/mangohud/default.nix"
            ])
          ) (flake-linter-lib.walkFlake ./.)
        );

        linter = flake-linter-lib.makeFlakeLinter {
          root = ./.;

          settings = {
            markdownlint = {
              paths = paths.markdown;
              settings = {
                MD013 = false;
              };
            };

            nixf-tidy-fix = {
              paths = paths.nix;
              settings = {
                variable-lookup = true;
              };
            };

            nixfmt-rfc-style.paths = paths.nix;

            prettier.paths = paths.markdown;
          };
        };

        nurPkgs = import ./pkgs { inherit lib; } (pkgs // nurPkgs) pkgs;

        flatNurPkgs = flake-utils.lib.flattenTree nurPkgs;
      in
      rec {
        packages = flake-utils.lib.filterPackages system flatNurPkgs;

        checks = packages // {
          flake-linter = linter.check;
        };

        apps = {
          sync = {
            type = "app";
            program = lib.getExe (
              nurPkgs.callPackage ./maintainers/scripts/sync.nix {
                nix-fast-build = nix-fast-build.packages.${system}.default;
                inherit nixpkgs;
              }
            );
          };

          update = {
            type = "app";
            program = toString (
              nurPkgs.callPackage ./maintainers/scripts/update.nix {
                packages = builtins.concatMap (
                  name:
                  let
                    package = flatNurPkgs.${name};
                    attrPath = builtins.replaceStrings [ "/" ] [ "." ] name;
                  in
                  if package ? updateScript then [ { inherit package attrPath; } ] else [ ]
                ) (builtins.attrNames flatNurPkgs);

                inherit nixpkgs;
              }
            );
          };

          inherit (linter) fix;
        };
      }
    );
}
