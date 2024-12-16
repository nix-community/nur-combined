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
              "gemset.nix"

              "nixos/modules/hardware/video/intel-gpu-tools.nix"
              "nixos/modules/hardware/xpadneo.nix"
              "nixos/modules/programs/bash/undistract-me.nix"
              "nixos/modules/programs/gamemode.nix"

              "nixos/tests/xpadneo.nix"

              "pkgs/applications/audio/zynaddsubfx/default.nix"
              "pkgs/applications/audio/zynaddsubfx/mruby-zest/default.nix"
              "pkgs/applications/networking/cluster/krane/default.nix"
              "pkgs/applications/version-management/git-review/default.nix"
              "pkgs/development/tools/misc/cmake-language-server/default.nix"
              "pkgs/development/tools/misc/texlab/default.nix"
              "pkgs/os-specific/linux/xpadneo/default.nix"
              "pkgs/tools/audio/yabridge/default.nix"
              "pkgs/tools/audio/yabridgectl/default.nix"
              "pkgs/tools/games/gamemode/default.nix"
              "pkgs/tools/graphics/mangohud/default.nix"
              "pkgs/tools/graphics/vkbasalt/default.nix"

              "pkgs/by-name/cl/clonehero/package.nix"
              "pkgs/by-name/mo/mozlz4a/package.nix"
              "pkgs/by-name/po/poke/package.nix"
              "pkgs/by-name/uk/ukmm/package.nix"
              "pkgs/by-name/un/undistract-me/package.nix"
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
