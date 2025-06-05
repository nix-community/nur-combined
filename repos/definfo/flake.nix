{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    # See https://flake.parts/module-arguments for module arguments
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        ...
      }:
      {
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
            ...
          }:
          {
            treefmt = {
              projectRootFile = ".git/config";
              settings.global.excludes = [
                ".github/dependabot.yml"
                "garnix.yaml"
                "LICENSE"
                "README.md"
              ];

              programs = {
                actionlint.enable = true;
                deadnix.enable = true;
                mdformat.enable = true;
                nixfmt.enable = true;
                statix.enable = true;
              };
            };

            # https://flake.parts/options/git-hooks-nix.html
            # Example: https://github.com/cachix/git-hooks.nix/blob/master/template/flake.nix
            pre-commit.settings.addGcRoot = true;
            pre-commit.settings.hooks = {
              commitizen.enable = true;
              eclint.enable = true;
              editorconfig-checker.enable = true;
              markdownlint.enable = true;
              treefmt.enable = true;
            };

            legacyPackages = import ./default.nix { inherit pkgs; };

            packages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;

            devShells.default = pkgs.mkShell {
              shellHook = ''
                ${config.pre-commit.installationScript}
                echo 1>&2 "Welcome to the development shell!"
              '';
              packages = config.pre-commit.settings.enabledPackages;
            };
          };
        flake = {
          updateArgs = {
            aya-prover = "--version-regex 'v(.*)'";
            sjtu-canvas-helper = "--version-regex 'app-v(.*)'";
            smartdns-rs = "--version-regex 'v(.*)'";
          };
        };
      }
    );
}
