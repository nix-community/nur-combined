# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{lib, ...}: {
  flake.lib = import ./library.nix {inherit lib;};
}
