# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs = {
    browserpass = {
      enable = true;
      browsers = [ "chrome" ];
    };
    password-store = {
      enable = true;
      package = pkgs.pass-wayland.withExtensions (exts: with exts; [
        pass-otp
        pass-update
        pass-checkup
      ]);
    };
  };
}
