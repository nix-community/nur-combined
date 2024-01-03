# SPDX-FileCopyrightText: 2023 winston <hey@winston.sh>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  xdg = {
    enable = true;
    mime.enable = isLinux;
    userDirs = {
      enable = isLinux;
      createDirectories = true;
    };
  };
}
