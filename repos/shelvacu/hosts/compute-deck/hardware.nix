{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "sdhci_pci"
    "dwc3_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  /*
    fileSystems."/" =
      { device = "/dev/disk/by-uuid/63f25199-ee0b-4991-8861-c3ba3b464ef2";
        fsType = "btrfs";
        options = [ "subvol=root" ];
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/63f25199-ee0b-4991-8861-c3ba3b464ef2";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/63f25199-ee0b-4991-8861-c3ba3b464ef2";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/63f25199-ee0b-4991-8861-c3ba3b464ef2";
        fsType = "btrfs";
        options = [ "subvol=boot" ];
      };
  */

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2aad8cab-7b97-47de-8608-fe9f12e211a4";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-uuid/C268-79C8";
    fsType = "vfat";
    options = [ "nofail" ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
