# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ inputs, ... }:
{
  perSystem = { system, config, pkgs, lib, ... }: {
    devShells.nix = pkgs.mkShell {
      name = "nix-shell";

      packages =
        (with pkgs;[
          vulnix
          statix
          deadnix
          nixpkgs-fmt
        ]) ++ (with inputs;[
          nil.packages.${system}.default
          nix-init.packages.${system}.default
          nix-update.packages.${system}.default
          nixpkgs-review.packages.${system}.default
        ]);
    };
  };
}
