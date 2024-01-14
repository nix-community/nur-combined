# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 =?UTF-8?q?J=C3=B6rg=20Thalheim?= <joerg@thalheim.io>
# SPDX-FileCopyrightText: 2023 Weathercold <weathercold.scr@proton.me>
#
# SPDX-License-Identifier: MIT

{ flake, ezModules, config, pkgs, lib, ... }:
{
  imports = [
    ezModules.user-root
    ezModules.user-procyon
    ezModules.profile-nix
    ezModules.profile-zram
    ezModules.profile-sops
    ezModules.profile-shells
    ezModules.profile-localization
    ezModules.networking-tailscale
    flake.inputs.nur.nixosModules.nur
    flake.inputs.disko.nixosModules.disko
  ];

  users.mutableUsers = false;

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  system = {
    inherit (flake.selfLib.data) stateVersion;
    activationScripts.diff = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff \
        /run/current-system "$systemConfig"
    '';
  };
}
