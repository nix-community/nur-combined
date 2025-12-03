{ config, lib, ... }:
{
  vacu.packages = [ config.services.fwupd.package ];
  services.fwupd.enable = true;
  #fwupd gets confused by the multiple EFI partitions, I think I just have to pick one
  #update: it didn't work, I dunno why. Leaving this here anyways
  services.fwupd.daemonSettings.EspLocation = lib.mkForce "/boot0";
}
