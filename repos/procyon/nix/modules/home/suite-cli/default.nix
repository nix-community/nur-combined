# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ ezModules, pkgs, lib, ... }:
{
  imports = [
    ezModules.profile-bat
    ezModules.profile-direnv
    ezModules.profile-eza
    ezModules.profile-fzf
    ezModules.profile-git
    ezModules.profile-gpg
    ezModules.profile-helix
    ezModules.profile-hyfetch
    ezModules.profile-jq
    ezModules.profile-just
    ezModules.profile-nix-index
    ezModules.profile-pass
    ezModules.profile-ripgrep
    ezModules.profile-ssh
    ezModules.profile-starship
    ezModules.profile-yazi
    ezModules.profile-zoxide
  ];

  home.packages = lib.attrValues {
    inherit (pkgs)
      taplo
      typst
      marksman
      ;
  };
}
