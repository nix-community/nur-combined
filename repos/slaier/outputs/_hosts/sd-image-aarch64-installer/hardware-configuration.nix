{ inputs, ... }:
{ pkgs, ... }:
{
  imports = with inputs; [
    (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix")
  ];

  hardware.deviceTree = {
    enable = true;
    name = "n1.dtb";
    kernelPackage = pkgs.uboot-phicomm-n1;
  };

  sdImage.populateFirmwareCommands = ''
    cp ${pkgs.uboot-phicomm-n1}/{s905_autoscript,uboot} firmware/
  '';
  sdImage.compressImage = false;

  nixpkgs.hostPlatform = "aarch64-linux";
}
