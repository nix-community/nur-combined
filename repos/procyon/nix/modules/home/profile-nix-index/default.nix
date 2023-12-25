# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ flake, ... }:
{
  imports = [
    flake.inputs.nix-index-database.hmModules.nix-index
  ];

  programs = {
    nix-index.enable = true;
    command-not-found.enable = false;
    nix-index-database.comma.enable = true;
  };
}
