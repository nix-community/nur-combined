# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{
  self,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];

  perSystem = {config, ...}: {
    overlayAttrs.infinitivewitch = lib.recurseIntoAttrs config.legacyPackages;
  };

  flake = {
    overlays =
      import ./overrides.nix
      // {
        infinitivewitch = self.overlays.default;
        singleRepoNur = final: prev: {
          nur =
            lib.recursiveUpdate (prev.nur or {})
            (lib.recurseIntoAttrs {
              repos = lib.recurseIntoAttrs (self.overlays.infinitivewitch final prev);
            });
        };
      };
  };
}
