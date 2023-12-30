# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ lib, newScope, selfLib, ... }:
lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
    recursiveApps = path: (callPackage path {
      inherit selfLib;
      selfPackages = self;
    });
  in
  {
    sources = callPackage ./_sources/generated.nix { };

    cockpit-podman = callPackage ./cockpit-podman { };
    cockpit-machines = callPackage ./cockpit-machines { };

    devPackages = lib.recurseIntoAttrs (recursiveApps ./dev-packages);

    wallpapers = lib.recurseIntoAttrs (recursiveApps ./wallpapers);
  }
)
