{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "iommu=pt"
  ];

  fileSystems."/" =
    {
      device = "none";
      fsType = "tmpfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/82A2-5715";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/6529aca8-b6ab-48bf-b6d1-6034b01a9830";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/data" =
    {
      device = "/dev/disk/by-uuid/13ad50f4-8269-43a5-9fb9-adb1919a5f3c";
      fsType = "btrfs";
    };

  services.fstrim.enable = true;

  swapDevices = [ ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc"
      "/var/lib"
      "/var/log/journal"
    ];
    users.nixos = {
      directories = [
        ".Genymobile"
        ".cache"
        ".config"
        ".local"
        ".mozilla"
        ".nali"
        ".ssh"
        "repos"
      ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
