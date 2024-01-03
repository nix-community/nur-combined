# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  programs.ripgrep.enable = true;

  home.packages = lib.attrValues {
    inherit (pkgs)
      fd
      sd
      ;
  };
}
