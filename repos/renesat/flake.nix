{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:chvp/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = import ./overlays.nix;
          config = {};
        };

        packages = import ./default.nix {
          inherit pkgs;
          inherit system;
        };

        pre-commit.settings.hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };

        devshells.default = {
          packages = [
          ];

          commands = [
            {
              package = pkgs.alejandra;
              help = "Format nix code";
            }
            {
              package = pkgs.statix;
              help = "Lint nix code";
            }
            {
              package = pkgs.deadnix;
              help = "Find unused expressions in nix code";
            }
            {
              package = pkgs.nix-tree;
              help = "Interactively browse dependency graphs of Nix derivations";
            }
            {
              package = pkgs.nvd;
              help = "Diff two nix toplevels and show which packages were upgraded";
            }
            {
              package = pkgs.nix-diff;
              help = "Explain why two Nix derivations differ";
            }
            {
              package = pkgs.nix-output-monitor;
              help = "Nix Output Monitor (a drop-in alternative for `nix` which shows a build graph)";
            }
            {
              package = pkgs.nix-update;
              help = "Nix utils for update packages";
            }
          ];

          devshell.startup.pre-commit.text = config.pre-commit.installationScript;

          env = [
          ];
        };

        # `nix fmt`
        formatter = pkgs.alejandra;
      };
    };
  #   flake-utils.lib.eachDefaultSystem (system: let
  #     pkgs = import nixpkgs {
  #       inherit system;
  #       overlays = import ./overlays.nix;
  #     };
  #   in rec {
  #     packages = import ./default.nix {
  #       inherit pkgs;
  #       inherit system;
  #     };

  # devShells = {
  #       default = pkgs.mkShell rec {
  #         buildInputs = with pkgs; [
  #           python3
  #           python3Packages.pip
  #           nix-update
  #         ];
  #       };
  #     };
  #   });
}
