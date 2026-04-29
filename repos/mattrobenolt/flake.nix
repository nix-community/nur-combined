{
  description = "mattrobenolt's nixpkgs";

  nixConfig = {
    extra-substituters = [ "https://mattrobenolt.cachix.org" ];
    extra-trusted-public-keys = [
      "mattrobenolt.cachix.org-1:sn1IDSC4OxQvWaOVD4RRcqyKlket5wgb11nd1QII6i8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packageSet = import ./lib/packages.nix { inherit (nixpkgs) lib; };

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ packageSet.overlay ];
          };

          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";

            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              ruff-format.enable = true;
            };

            settings = {
              global.excludes = [
                ".direnv/**"
              ];

              formatter = {
                deadnix.priority = 1;
                statix.priority = 2;
                nixfmt.priority = 3;
              };
            };
          };
        in
        {
          packages = packageSet.packagesFor pkgs;
          formatter = treefmtEval.config.build.wrapper;
          checks.formatting = treefmtEval.config.build.check self;

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.python3
              pkgs.zon2nix
              treefmtEval.config.build.wrapper
              pkgs.nix-tree
              pkgs.nix-diff
            ];

            shellHook = ''
              just --list --unsorted
            '';
          };
        };

      allSystems = forAllSystems perSystem;
    in
    {
      overlays.default = packageSet.overlay;

      templates = {
        go = {
          path = ./templates/go;
          description = "Go development environment";
        };

        zig = {
          path = ./templates/zig;
          description = "Zig development environment";
        };

        bun = {
          path = ./templates/bun;
          description = "Bun development environment";
        };

        rust = {
          path = ./templates/rust;
          description = "Rust development environment";
        };

        python = {
          path = ./templates/python;
          description = "Python development environment";
        };
      };

      defaultTemplate = self.templates.go;

      packages = builtins.mapAttrs (_: s: s.packages) allSystems;
      formatter = builtins.mapAttrs (_: s: s.formatter) allSystems;
      checks = builtins.mapAttrs (_: s: s.checks) allSystems;
      devShells = builtins.mapAttrs (_: s: s.devShells) allSystems;
    };
}
