# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, config, pkgs, lib, ... }:
{
  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;

  home = {
    inherit (flake.selfLib.data) stateVersion;
    username = lib.mkDefault flake.config.people.myself;
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}";
  };
}
