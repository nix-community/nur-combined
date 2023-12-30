# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ lib, newScope, ... }:
lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
rec {
  default = wallhaven-m9jezy;
  wallhaven-m9jezy = callPackage ./wallhaven-m9jezy.nix { };
})
