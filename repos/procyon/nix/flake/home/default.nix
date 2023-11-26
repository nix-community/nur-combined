# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
#
# SPDX-License-Identifier: MIT

{ self, lib, ... }:
{
  perSystem = { pkgs, ... }: {
    legacyPackages.homeConfigurations.devcontainer = self.lib.mkHomeConfiguration
      pkgs
      ({ config, pkgs, ... }: {
        home.username = lib.mkForce "vscode";
        imports = with self.homeModules; [ direnv ];
      });
  };
}
