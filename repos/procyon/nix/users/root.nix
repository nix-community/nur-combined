# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ osConfig, lib, ... }:
{
  home = {
    username = lib.mkForce "root";
    homeDirectory = lib.mkForce osConfig.users.users.root.home;
  };
}
