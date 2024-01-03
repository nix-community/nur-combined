# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ ezModules, lib, ... }:
{
  imports = [
    ezModules.roles-workstation
    ezModules.disko-ext4-vanilla
    ezModules.hardware-chromebook
  ];

  _module.args.disks = [ "/dev/nvme0n1" ];

  hardware.logitech.wireless.enable = true;

  networking.hostName = "lenovo-chromebook";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
