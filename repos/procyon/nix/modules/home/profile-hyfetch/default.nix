# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  programs.hyfetch.enable = true;

  home.packages = lib.attrValues {
    inherit (pkgs)
      nitch
      bunnyfetch
      ;
  };
}
