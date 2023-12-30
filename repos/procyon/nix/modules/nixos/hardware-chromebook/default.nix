# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, ezModules, pkgs, lib, ... }:
{
  imports = [
    ezModules.chromebook-keyd
    ezModules.chromebook-audio
    ezModules.bootloader-grub
    ezModules.profile-plymouth
  ] ++ (with flake.inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-pc-laptop
    common-pc-laptop-ssd
    common-pc-laptop-acpi_call
  ]);

  hardware.sensor.iio.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  environment = {
    systemPackages = with pkgs; [ alsa-ucm-conf ];
    sessionVariables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf}/share/alsa/ucm2";
  };

  boot = {
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "iomem=relaxed" ];
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "uas" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options snd-intel-dspcfg dsp_driver=3
    '';
  };
}
