{ config, pkgs, lib, inputs, materusFlake, ... }:
let 
video = [
  
  "video=HDMI-A-3:1920x1080@144"
  "video=DP-3:1920x1080@240"
  

  #"video=DP-1:1920x1080@240"
  #"video=DP-2:1920x1080@240"
  #"video=HDMI-A-1:1920x1080@240"
  #"video=HDMI-A-2:1920x1080@240"
  

];
in 
{
  #Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ /*"pci-stub.ids=1002:744c"*/ "nox2apic" "nvme_core.default_ps_max_latency_us=0" "nvme_core.io_timeout=255" "nvme_core.max_retries=10" "nvme_core.shutdown_timeout=10" "amd_iommu=on" "iommu=pt"] ++ video;
  boot.kernelModules = [ "pci-stub" "amdgpu" "i2c_dev" "kvm_amd" "vfio" "vfio_iommu_type1" "vfio-pci" "v4l2loopback" ];
  boot.extraModprobeConfig = ''
  options kvm_amd nested=1 avic=1 npt=1
  options vfio_iommu_type1 allow_unsafe_interrupts=1
  '';
  boot.kernel.sysctl = {
                        "vm.max_map_count" = 1000000;
                        "vm.swappiness" = 10;
                       };
  
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  

  boot.supportedFilesystems = [ "ntfs" "btrfs" "vfat" "exfat" "ext4"];

  boot.tmp.useTmpfs = true;


  #bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    gfxmodeEfi = pkgs.lib.mkDefault "1920x1080@240";
    gfxmodeBios = pkgs.lib.mkDefault "1920x1080@240";
    useOSProber = true;
    memtest86.enable = true;
  };
}
