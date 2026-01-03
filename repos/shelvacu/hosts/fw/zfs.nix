{ ... }:
{
  boot.zfs.extraPools = [ "fw" ];
  systemd.services.zfs-mount.enable = false;
}
