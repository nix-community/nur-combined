# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
{
  home = {
    file.".user.justfile".source = "${flake.self}/nix/modules/home/profile-just/justfile";

    packages = with pkgs; [
      just
      gum
    ];

    shellAliases = {
      "j" = "just";
      ".j" = "just --justfile ~/.user.justfile --working-directory $PWD";
      "~j" = "just --justfile ~/.user.justfile --working-directory $HOME";
    };
  };
}
