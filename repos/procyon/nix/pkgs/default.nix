# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ lib, newScope, ... }:
lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    cockpit-podman = callPackage ./cockpit-podman { };
  }
)
