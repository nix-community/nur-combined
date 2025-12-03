{ lib, ... }:
let
  btrfsopts = [
    "noatime"
    "compress=zstd"
  ];
in
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "xhci_hcd"
    "uas"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2f8b5094-94ab-4634-b11b-d4bcd2dc3f24";
    fsType = "btrfs";
    options = [ "subvol=root" ] ++ btrfsopts;
  };

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/4e75b9ed-ac4f-48a2-b38c-c5026723171f";
    # note: creation requires --new-key-file-size not --key-file-size
    keyFileSize = 2048;
    keyFile = "/dev/disk/by-partuuid/9d171b52-329e-4e21-9399-dcc66ff572cd";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4407-1EF3";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
      "nofail"
    ];
  };

  fileSystems."/nix/store" = {
    device = "/dev/disk/by-uuid/2f8b5094-94ab-4634-b11b-d4bcd2dc3f24";
    fsType = "btrfs";
    options = [ "subvol=nix-store" ] ++ btrfsopts;
  };

  fileSystems."/btrfs-root" = {
    device = "/dev/disk/by-uuid/2f8b5094-94ab-4634-b11b-d4bcd2dc3f24";
    fsType = "btrfs";
    options = [
      "subvol=/"
      "noauto"
    ]
    ++ btrfsopts;
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.end0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;
}
