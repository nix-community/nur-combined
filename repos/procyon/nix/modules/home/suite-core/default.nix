# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ osConfig, ezModules, ... }:
{
  imports = [
    ezModules.profile-direnv
    ezModules.profile-git
    ezModules.profile-gpg
    ezModules.profile-nix-index
    ezModules.profile-ssh
    ezModules.profile-starship
  ];

  programs = {
    bash.enable = true;
    zsh.enable = osConfig.programs.zsh.enable;
    fish.enable = osConfig.programs.fish.enable;
  };
}
