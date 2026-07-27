{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
    ../home/backup.nix
  ];

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;

      # Skip the boot selection menu. In order to open it again, repeatedly press the space key on boot.
      timeout = 0;
    };

    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    kernelParams = [ "amdgpu.dc=1" ];
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "snd_hda_codec_hdmi" ]; # Disable HDMI audio
  };

  networking.hostName = "xenon";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b9f43929-9b6e-4a05-82fc-f2820a3b2249";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0432-52B8";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/2854a56b-660f-4add-8bfa-9efb36a1cc01"; }
    ];

  nix.maxJobs = 24;
  nix.buildCores = 24;

  # AMD polaris firmware
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [ steam ];

  services.xserver = {
    videoDrivers = [ "amdgpu" "modesetting" "vesa" ];
    config = ''
      Section "Monitor"
        Identifier "DisplayPort-0"
        VertRefresh 144.0 - 144.0
      EndSection
      Section "Monitor"
        Identifier "DVI-D-0"
        Option "LeftOf" "DisplayPort-0"
      EndSection
      Section "Device"
        Identifier "AMD"
        Driver "amdgpu"
        Option "TearFree" "true"
      EndSection
      Section "InputClass"
        Identifier "Logitech G403 Prodigy Gaming Mouse"
        MatchIsPointer "yes"
        Option "AccelerationProfile" "-1"
        Option "AccelerationScheme" "none"
        Option "AccelSpeed" "-1"
        Option "Resolution" "3500"
      EndSection
    '';
  };
}
