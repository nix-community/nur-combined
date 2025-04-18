##########################################################################
#                                                                        #
#  This file is part of the shackra/nur project                          #
#                                                                        #
#  Copyright (C) 2025 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  description = "Jorge's personal NUR packages";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.*"; # current stable
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      pre-commit-hooks,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            packages = self.checks.${system}.pre-commit-check.enabledPackages;
          };
        }
      );
      packages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      checks = forAllSystems (
        system:
        let
          packagesForSystem = self.packages.${system};
        in
        packagesForSystem
        // {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nil.enable = true;
              flake-checker.enable = true;
              statix.enable = true;
              # misc.
              trim-trailing-whitespace.enable = true;
              check-case-conflicts.enable = true;
              end-of-file-fixer.enable = true;
              headache = {
                enable = true;
                entry = "headache -c headache.conf -h headache.header.txt";
                files = "all";
              };
            };
          };
        }
      );
    };
}
