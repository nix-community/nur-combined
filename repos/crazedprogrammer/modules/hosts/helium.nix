{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
  ];

  boot = {
    loader.grub = {
      # Use GRUB for booting.
      device = "/dev/sda";
      efiSupport = false;
      gfxmodeBios = "1920x1080";
      splashImage = if builtins.pathExists ../../../Pictures/Boot.png
        then ../../../Pictures/Boot.png
        else "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/artwork/gnome/nix-wallpaper-simple-dark-gray.png";
      # Dual boot.
      extraEntries = ''
        menuentry "Windows 10" {
          insmod part_msdos
          insmod ntfs
          insmod search_fs_uuid
          insmod ntldr
          search --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1 F234E48B34E4545F
          ntldr /bootmgr
        }
        menuentry "System Shutdown" {
          echo "System shutting down..."
          halt
        }
      '';
    };

    initrd.availableKernelModules = [ "bcache" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    kernelParams = [ "i915.enable_psr=1" "i915.i915_enable_fbc=1" ];

    kernelPackages = import ../home/kernel (pkgs // {
      structuredExtraConfig = {
        MSKYLAKE = "y";
        SND_HDA_POWER_SAVE_DEFAULT = "1";

        # We need this module early on, so compile it into the kernel image.
        BTRFS_FS = yes;
      };
    });
  };

  networking = {
    hostName = "helium"; # Hostname.
    hostId = "98345052";
    firewall.allowedTCPPorts = lib.range 12000 12100;
  };
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  fileSystems."/" =
    { device = "/dev/bcache0";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2061-9157";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6f01e112-8c69-4792-9945-6806c32ad451"; }
    ];


  nix.maxJobs = 4;
  nix.buildCores = 4;

  # Intel wifi firmware
  hardware.enableRedistributableFirmware = true;

  services.logind.lidSwitch = "ignore";
  powerManagement = {
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];

  services.xserver = {
    synaptics = {
      enable = true;
      minSpeed = "1";
      accelFactor = "0.002";
      maxSpeed = "2";
      twoFingerScroll = true;
      scrollDelta = -75;
      palmDetect = true;
      additionalOptions = ''
        Option "PalmMinWidth" "4"
        Option "PalmMinZ" "50"
      '';
    };
    config = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "intel"
        Option "TearFree" "true"
      EndSection
    '';
  };
}
