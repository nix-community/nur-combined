# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{...}: {
  systems = ["x86_64-linux"];

  imports = [
    ./apps
    ./checks
    ./devshells
    ./formatter
    ./lib
    ./modules
    ./overlays
    ./packages
  ];
}
