{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  powerManagement.enable = false;

  hardware.cpu = {
    profile = {
      cores = 24;
      speed = 4;
    };
    amd.updateMicrocode = true;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    blacklistedKernelModules = [ "e1000e" ];

    supportedFilesystems = [ "zfs" ];
    kernelParams = [ "amd_iommu=on" ];

    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "sd_mod" ];
      kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    };

    kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    # kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    extraModprobeConfig = "options vfio-pci ids=8086:105e,8086:105e";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/910a3375-cfe7-4c14-a6ec-5f2c1306548a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0372-A22D";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/de692380-3788-4375-8afb-33a6195fa9e6"; }];
}
