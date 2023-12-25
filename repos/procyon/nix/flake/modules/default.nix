# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ self, inputs, lib, ... }:
{
  imports = [
    inputs.ez-configs.flakeModule
  ] ++ lib.attrValues (import ../../modules/flake);

  flake.flakeModules = import ../../modules/flake;

  ezConfigs = {
    inherit (self.lib) globalArgs;

    root = "${self}/.";
    nixos = {
      modulesDirectory = "${self}/nix/modules/nixos";
      configurationsDirectory = "${self}/nix/hosts/nixos";
    };
    darwin = {
      modulesDirectory = "${self}/nix/modules/darwin";
      configurationsDirectory = "${self}/nix/hosts/darwin";
    };
    home = {
      modulesDirectory = "${self}/nix/modules/home";
      configurationsDirectory = "${self}/nix/users";
    };
  };
}
