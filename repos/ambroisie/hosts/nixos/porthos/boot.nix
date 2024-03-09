# Boot configuration
{ ... }:

{
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [ "kvm-intel" ];

    extraModulePackages = [ ];
  };
}
