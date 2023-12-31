# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ inputs, ... }:
{
  perSystem = { system, self', config, pkgs, lib, ... }:
    {
      checks = inputs.flake-utils.lib.flattenTree { devShells = lib.recurseIntoAttrs self'.devShells; };

      devShells.default = pkgs.mkShell {
        name = "flake-shell";

        shellHook = ''
          source ${config.pre-commit.installationScript}
        '';

        inputsFrom = with config; [
          flake-root.devShell
          treefmt.build.devShell
          self'.devShells.nix
          self'.devShells.sops
        ];

        packages = with pkgs; with inputs; [
          hci
          reuse
          terraform
          deploy-rs.packages.${system}.deploy-rs
        ];
      };
    };
}
