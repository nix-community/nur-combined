# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ ... }:
{
  programs.ssh = {
    enable = true;
    includes = [ "config.d/*" ];
  };

  home.file.".ssh/config.d/managed".text = ''
    Host *
      ControlPath ~/.ssh/%C
  '';
}
