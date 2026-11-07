{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # TODO: Keep this existing UUID-based layout. Consider disko only for a fresh NixOS installation or a planned disk-layout change.
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [];
    kernelModules = [
      # Enable hardware-accelerated virtualization for AMD processors.
      "kvm-amd"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/16a8ee7a-960c-4ab5-a7f9-7b3c642f3e55";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/45C2-8105";
      fsType = "vfat";
      options = [
        # Restrict file and directory permissions on FAT filesystem to owner only
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/run/media/ac/hdd" = {
      device = "/dev/disk/by-uuid/68004D20004CF69A";
      fsType = "ntfs-3g";
      options = [
        "auto"
        "nofail"
        "user"
        # This data disk does not run binaries or scripts directly.
        "noexec"
        "uid=1000"
        "gid=100"
        "umask=022"
        "utf8"
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Load AMD CPU microcode updates when redistributable firmware is permitted.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
