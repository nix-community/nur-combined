{ config, pkgs, lib, inputs, materusFlake, ... }:
{
  #Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=0" "nvme_core.io_timeout=255" "nvme_core.max_retries=10" "nvme_core.shutdown_timeout=10" "amd_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" ];
  boot.kernelModules = [ "i2c_dev" "kvm_amd" "vfio-pci" "v4l2loopback" "kvmfr" ];
  boot.extraModprobeConfig = ''
  options kvm_amd nested=1
  '';
  boot.kernel.sysctl = {"vm.max_map_count" = 1000000;};
  
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback kvmfr];
  

  boot.supportedFilesystems = [ "ntfs" "btrfs" "vfat" "exfat" "ext4"];

  boot.tmp.useTmpfs = true;


  #bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    gfxmodeEfi = pkgs.lib.mkDefault "1920x1080";
    gfxmodeBios = pkgs.lib.mkDefault "1920x1080";
    useOSProber = true;
    memtest86.enable = true;
  };
}
