# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  newScope,
  ...
}:
lib.makeScope newScope (
  self: let
    inherit (self) callPackage;
  in {
    sources = callPackage ./_sources/generated.nix {};

    eupnea-scripts = callPackage ./eupnea-scripts {};
  }
)
