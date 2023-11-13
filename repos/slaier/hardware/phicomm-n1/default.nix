{ lib, pkgs, config, ... }:

{
  imports = [
    ./dtos.nix
    ./dwc2.nix
    ./wireless.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "usb_storage"
    ];

    consoleLogLevel = lib.mkDefault 7;

    kernelParams = lib.mkDefault [
      "console=ttyAML0,115200n8"
      "console=tty1"
    ];

    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };
  };
}
