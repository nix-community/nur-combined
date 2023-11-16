{ lib, ... }:
let
  inherit (lib) mkDefault;
in
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

    consoleLogLevel = mkDefault 7;

    kernelParams = mkDefault [
      "console=ttyAML0,115200n8"
      "console=tty1"
    ];

    loader = {
      grub.enable = mkDefault false;
      generic-extlinux-compatible.enable = mkDefault true;
    };
  };
}
