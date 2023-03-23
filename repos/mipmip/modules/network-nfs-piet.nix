{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/mnt/piethein" = {
    device = "192.168.13.37:/volume1/HurwenenShare";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/piethein2" = {
    device = "192.168.13.37:/volume1/Archief";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/piethein3" = {
    device = "192.168.13.37:/volume1/CathalijneArchief";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
}
