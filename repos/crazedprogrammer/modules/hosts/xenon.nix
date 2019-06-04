{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
  ];

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      # Skip the boot selection menu. In order to open it again, repeatedly press the space key on boot.
      timeout = 0;
    };

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    kernelParams = [ "amdgpu.dc=1" ];
    kernelModules = [ "kvm-amd" ];
    kernelPatches = [ {
      name = "config-xenon";
      patch = null;
      extraConfig = ''
        MZEN y
        DRM_I915 n
        FB_NVIDIA_I2C n
        DRM_NOUVEAU n
      '';
    } ];
  };

  networking.hostName = "xenon"; # Define your hostname.

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8ee00b41-b4a1-4290-a01e-8b8788841c76";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A024-0A4C";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4133fbc7-683f-4267-a6fb-126c7e80e29b"; }
    ];

  nix.maxJobs = 12;
  nix.buildCores = 12;

  environment.systemPackages = with pkgs; [
    hdparm
  ];

  # AMD polaris firmware
  hardware.enableRedistributableFirmware = true;

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
      # TODO: fix screen tearing
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
