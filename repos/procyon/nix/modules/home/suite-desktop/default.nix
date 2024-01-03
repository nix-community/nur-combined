# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ ezModules, ... }:
{
  imports = [
    ezModules.profile-gnome
    ezModules.profile-gtk
    ezModules.profile-dconf
    ezModules.profile-kitty
    ezModules.profile-chrome
    ezModules.profile-spotify
  ];

  xsession.enable = true;
}
