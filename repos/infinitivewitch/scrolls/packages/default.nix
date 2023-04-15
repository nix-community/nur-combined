# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{
  self,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  perSystem = {
    self',
    pkgs,
    ...
  }: {
    packages = inputs.flake-utils.lib.flattenTree (self'.legacyPackages);
    legacyPackages = self.lib.makePackages pkgs ./pkgs {
      selfLib = self.lib;
    };
  };
}
