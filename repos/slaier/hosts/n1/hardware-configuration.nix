{ config, lib, pkgs, ... }:
{
  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "iommu.passthrough=1"
  ];

  hardware.deviceTree = {
    enable = true;
    name = "n1.dtb";
    kernelPackage = pkgs.uboot-phicomm-n1;
  };

  # Only enable wireless firmware to save disk space.
  hardware.firmware = with pkgs; [
    (runCommand "wireless-firmware-n1" { } ''
      mkdir -p $out
      cd ${raspberrypiWirelessFirmware}
      cp --no-preserve=mode -t $out --parents lib/firmware/brcm/brcmfmac43455-sdio.{bin,clm_blob,txt}
    '')
  ];

  fileSystems."/" =
    {
      device = "/dev/mmcblk1p2";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/6454-42EE";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
