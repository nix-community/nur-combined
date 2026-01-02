{ inputs, vaculib, ... }:
{
  imports = [ inputs.nixos-apple-silicon.nixosModules.default ] ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "mmm";
  vacu.shell.color = "red";
  vacu.verifySystem.enable = false;
  vacu.verifySystem.expectedMac = "14:98:77:3f:b8:2e";
  vacu.systemKind = "server";

  # asahi recommends systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
