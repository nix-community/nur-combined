# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ inputs, self, ... }: {
  perSystem = { system, self', pkgs, lib, ... }:
    let
      config.allowUnfree = true;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system config;
      };

      packages = inputs.flake-utils.lib.flattenTree (self'.legacyPackages);

      legacyPackages = self.lib.makePackages pkgs ../../pkgs {
        selfLib = self.lib;
        inherit inputs;
      };

      checks =
        let
          pkgsStable = import inputs.nixpkgs-stable {
            inherit system config;
          };
          pkgsLatest = import inputs.nixpkgs-latest {
            inherit system config;
          };
        in
        inputs.flake-utils.lib.flattenTree {
          packages = lib.recurseIntoAttrs self'.legacyPackages;
          packages-stable = lib.recurseIntoAttrs (self.lib.makePackages pkgsStable ../../pkgs {
            selfLib = self.lib;
            inherit inputs;

          });
          packages-latest = lib.recurseIntoAttrs (self.lib.makePackages pkgsLatest ../../pkgs {
            selfLib = self.lib;
            inherit inputs;
          });
        };
    };
}
