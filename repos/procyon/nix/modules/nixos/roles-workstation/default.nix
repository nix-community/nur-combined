# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, ezModules, pkgs, lib, ... }:
{
  imports = [
    ezModules.audio-pipewire
    ezModules.profile-fonts
    ezModules.profile-gnome
  ];

  documentation.nixos.enable = false;

  networking.useDHCP = lib.mkDefault true;

  hardware.enableRedistributableFirmware = true;

  users.extraGroups.video.members = [ "${flake.config.people.myself}" ];

  services = {
    fwupd.enable = true;
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      libinput.touchpad.naturalScrolling = true;
    };
  };
}
