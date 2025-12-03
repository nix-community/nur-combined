{ inputs, ... }:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
    ./hardware.nix
  ];

  vacu.hostName = "mmm";
  vacu.shell.color = "red";
  vacu.verifySystem.enable = false;
  vacu.verifySystem.expectedMac = "14:98:77:3f:b8:2e";
  vacu.systemKind = "server";

  # asahi recommends systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
