{ ... }:

# syncing to backup zpool
#   syncoid storage/vmiso archive/downloads/vmiso
#   syncoid storage/vms archive/vms -r
#   syncoid storage/backup-hdexterno archive/backup-hdexterno

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "storage" ];
  };
}
