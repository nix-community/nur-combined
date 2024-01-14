# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ ... }:
{
  programs.eza = {
    git = true;
    icons = true;
    enable = true;
    enableAliases = true;
    extraOptions = [ "--group-directories-first" ];
  };
}
