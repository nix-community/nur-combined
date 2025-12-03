{
  config,
  lib,
  pkgs,
  vaculib,
  ...
}:
let
  wdc_sn530 = "/dev/disk/by-id/nvme-WDC_PC_SN530_SDBPNPZ-1T00-1006_214628801678";
  seagate_ironwolf = "/dev/disk/by-id/nvme-Seagate_IronWolf510_ZP960NM30001-2S9302_7PK0052S";
  nvmeDevices = [
    wdc_sn530
    seagate_ironwolf
  ];
  raidPartitions = map (s: s + "-part2") nvmeDevices;
  md_name = "prophecy-root-crypt";
  md_dev = "/dev/disk/by-id/md-name-${md_name}";
in
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "raid1" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    DEVICE ${lib.concatStringsSep " " raidPartitions}
    ARRAY ${md_name} metadata=1.2 UUID=9edfd1b4:0fb7fd0d:4f390f6d:3d176ddf
    AUTO -all
    PROGRAM ${pkgs.coreutils}/bin/echo
  '';

  boot.initrd.luks.devices."prophecy-root-decrypted" = {
    device = md_dev;
    allowDiscards = true;
    bypassWorkqueues = true;
  };
  boot.initrd.systemd.enable = true;
  vacu.packages = ''
    tpm2-tss
    mdadm
  '';

  fileSystems."/boot" = {
    device = "${wdc_sn530}-part1";
    fsType = "vfat";
    options = [
      "umask=${vaculib.mask { user = "allow"; }}"
      "nofail"
    ];
  };

  fileSystems."/boot-alt" = {
    device = "${seagate_ironwolf}-part1";
    fsType = "vfat";
    options = [
      "umask=${vaculib.mask { user = "allow"; }}"
      "nofail"
    ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;
}
