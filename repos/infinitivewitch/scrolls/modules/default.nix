# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{...}: {
  imports = [
    ./flake
    ./nixos
  ];

  flake = {
    flakeModules = import ./flake;
    nixosModules = import ./nixos;
  };
}
