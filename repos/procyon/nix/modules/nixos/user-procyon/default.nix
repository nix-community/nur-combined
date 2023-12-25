# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, ... }:
{
  users.users.procyon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    description = "Unidealistic Raccoon";
    initialHashedPassword = "$y$j9T$C4GPDU2bdN6l/I0K7qprU/$xfDoXKO7Aj/hxhj5E7Yo1ei.qAEwrgqqtvk60dBHHN.";
    openssh.authorizedKeys.keys = [
      "${flake.config.people.users.${flake.config.people.myself}.keys.ssh}"
    ];
  };
}
