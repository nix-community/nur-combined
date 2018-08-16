{
  mkHetznerVM = { name, ipv4, ipv6, users, boot, imports ? [], nixpkgs ? {}, hostName, rootPart, bootPart, swapPart }:
    {
      inherit imports nixpkgs boot users;

      i18n = {
        consoleFont = "Lat2-Terminus16";
        consoleKeyMap = "us";
        defaultLocale = "en_US.UTF-8";
      };

      nix = {
        autoOptimiseStore = true;
        useSandbox = true;
        maxJobs = 2;
        buildCores = 1;
      };

      programs = {
        bash.enableCompletion = true;
        mtr.enable = true;
      };

      services.openssh = {
        enable = true;
        permitRootLogin = "yes";
      };

      hardware.enableAllFirmware = false;

      systemd.enableEmergencyMode = true;
      networking = {
        inherit hostName;
        interfaces = {
          ens3 = {
            ipv4.addresses = [ { address = ipv4; prefixLength = 32; } ];
            ipv6.addresses = [ { address = ipv6; prefixLength = 64; } ];
          };
        };
        nameservers = [
          "213.133.98.98"   # \
          "213.133.99.99"   #  | hetzner
          "213.133.100.100" # /
          "2a01:4f8:0:a0a1::add:1010" # \
          "2a01:4f8:0:a102::add:9999" #  | hetzner
          "2a01:4f8:0:a111::add:9898" # /
        ];
        defaultGateway = { address = "172.31.1.1"; interface = "ens3"; };
        defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };
      };


      time.timeZone = "CET";

    fileSystems."/" =
      { device = rootPart;
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/${bootPart}";
        fsType = "ext2";
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/${swapPart}"; }
      ];
    };

  mkGrub = device: {
    enable = true;
    configurationLimit = 6;
    inherit device;
  };

  mkInitrd = devices: {
    availableKernelModules = [
      "ata_piix" "uhci_hcd" "sd_mod" "sr_mod" "virtio_pci" "virtio_scsi" "virtio_mmio" "9p" "9pnet_virtio"
    ];
    kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];

    luks = { inherit devices; };
  };
}
