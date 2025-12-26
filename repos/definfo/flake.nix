{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-24_05.url = "github:NixOS/nixpkgs/release-24.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      ...
    }:
    # See https://flake.parts/module-arguments for module arguments
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          pkgs,
          lib,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (_final: _prev: {
                inherit (inputs.nixpkgs-24_05.legacyPackages.${system}) jdk22;
              })
            ];
          };
          treefmt = {
            projectRootFile = "flake.nix";
            settings.global.excludes = [
              ".github/dependabot.yml"
              "garnix.yaml"
              "LICENSE"
            ];

            programs = {
              actionlint.enable = true;
              deadnix.enable = true;
              nixfmt.enable = true;
              shellcheck = {
                enable = true;
                package = pkgs.shellcheck-minimal;
              };
              shfmt.enable = true;
              statix.enable = true;
              # zizmor.enable = true;
            };
          };

          # https://flake.parts/options/git-hooks-nix.html
          # Example: https://github.com/cachix/git-hooks.nix/blob/master/template/flake.nix
          pre-commit.settings.package = pkgs.prek;
          pre-commit.settings.configPath = ".pre-commit-config.flake.yaml";
          pre-commit.settings.hooks = {
            commitizen.enable = true;
            eclint.enable = true;
            markdownlint.enable = true;
            treefmt.enable = true;
          };

          legacyPackages = import ./default.nix { inherit pkgs; };

          packages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.treefmt.build.devShell
              config.pre-commit.devShell
            ];
          };
        };
    };
}
