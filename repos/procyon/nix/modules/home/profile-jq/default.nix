# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  programs.jq.enable = true;

  home.packages = lib.attrValues {
    inherit (pkgs) yq;
  };
}
