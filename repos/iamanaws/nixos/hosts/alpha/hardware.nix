{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi02w;

    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;

      # override core defaults
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };

    extraModprobeConfig = ''
      options brcmfmac roamoff=1 feature_disable=0x82000
    '';

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [ ];

  hardware = {
    # needed for wlan0 to work (https://github.com/NixOS/nixpkgs/issues/115652)
    enableRedistributableFirmware = lib.mkForce false;
    firmware = with pkgs; [
      # This make sure wifi works
      raspberrypiWirelessFirmware
    ];

    i2c.enable = true;
    deviceTree.filter = "bcm2837-rpi-zero*.dtb";
    deviceTree.overlays = [
      {
        name = "enable-i2c";
        dtsText = ''
          /dts-v1/;
          /plugin/;
          / {
            compatible = "brcm,bcm2837";
            fragment@0 {
              target = <&i2c1>;
              __overlay__ {
                status = "okay";
              };
            };
          };
        '';
      }
    ];
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "aarch64-linux";

    buildPlatform.system = "x86_64-linux";
    config.allowUnsupportedSystem = true;
  };
}
