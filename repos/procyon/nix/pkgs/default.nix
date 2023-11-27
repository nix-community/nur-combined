# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ lib, newScope, selfLib, ... }:
lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    sources = callPackage ./_sources/generated.nix { };

    nvfetcher = lib.recurseIntoAttrs (callPackage ./nvfetcher {
      inherit selfLib;
      selfPackages = self;
    });

    cockpit-machines = callPackage ./cockpit-machines { };
    cockpit-podman = callPackage ./cockpit-podman { };
  }
)
