# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, lib, ... }:
{
  users.users.root = {
    shell = pkgs.zsh;
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = [ "${flake.config.people.users.${flake.config.people.myself}.keys.ssh}" ];
  };
}
