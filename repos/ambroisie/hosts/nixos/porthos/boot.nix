# Boot configuration
{ ... }:

{
  boot = {
    # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      # Define on which hard drive you want to install Grub.
      device = "/dev/sda";
    };

    initrd = {
      availableKernelModules = [ "uhci_hcd" "ahci" "usbhid" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [ "kvm-intel" ];

    extraModulePackages = [ ];
  };
}
