# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, lib, ... }:
{
  sound.enable = true;

  security.rtkit.enable = true;

  hardware.pulseaudio.enable = lib.mkForce false;

  users.extraGroups.audio.members = [ "${flake.config.people.myself}" ];

  environment.systemPackages = with pkgs; [
    pulseaudio
    easyeffects
  ];

  services.pipewire = {
    enable = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
}
