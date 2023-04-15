# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{lib, ...}: {
  imports = lib.attrValues (import ./flake);

  flake = {
    flakeModules = import ./flake;
    nixosModules = import ./nixos;
  };
}
