{ ... }:

# syncing to backup zpool
#   syncoid storage/vmiso archive/downloads/vmiso
#   syncoid storage/backup-hdexterno archive/backup-hdexterno
#   syncoid zroot/vms archive/vms -r

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "storage" "zroot" ];
  };
  virtualisation.docker.storageDriver = "zfs";
}
