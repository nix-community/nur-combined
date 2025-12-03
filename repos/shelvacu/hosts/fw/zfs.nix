{ pkgs, ... }:
{
  boot.zfs.extraPools = [ "fw" ];
  systemd.services.zfs-mount.enable = false;

  # see also fileSystems."/"
}
