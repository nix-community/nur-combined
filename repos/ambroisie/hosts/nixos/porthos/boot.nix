# Boot configuration
{ ... }:

{
  boot = {
    # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      # Define on which hard drive you want to install Grub.
      device = "/dev/disk/by-id/ata-HGST_HUS724020ALA640_PN2181P6J58M1P";
    };

    initrd = {
      availableKernelModules = [ "uhci_hcd" "ahci" "usbhid" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [ "kvm-intel" ];

    extraModulePackages = [ ];
  };
}
