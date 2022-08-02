{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/mnt/piethein" = {
    device = "192.168.13.37:/volume1/HurwenenShare";
    fsType = "nfs";
  };
  fileSystems."/mnt/piethein2" = {
    device = "192.168.13.37:/volume1/Archief";
    fsType = "nfs";
  };
  fileSystems."/mnt/piethein3" = {
    device = "192.168.13.37:/volume1/CathalijneArchief";
    fsType = "nfs";
  };
}

# 192.168.13.37:/volume1/HurwenenShare      /mnt/piethein nfs rsize=32768,wsize=32768,timeo=14,noatime,intr 0 0
# 192.168.13.37:/volume1/Archief            /mnt/piethein2 nfs rsize=32768,wsize=32768,timeo=14,noatime,intr 0 0
