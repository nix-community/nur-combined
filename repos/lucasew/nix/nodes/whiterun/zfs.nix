{ pkgs, ... }:

# syncing to backup zpool
#   syncoid storage/vmiso archive/downloads/vmiso
#   syncoid storage/backup-hdexterno archive/backup-hdexterno
#   syncoid zroot/vms archive/vms -r

{
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "zroot" ];
  };
  boot.zfs = {
    package = pkgs.zfs_2_4;
    forceImportRoot = false;
    requestEncryptionCredentials = [ "zroot" ];
    # extraPools = [ "storage" ];
  };
  virtualisation.docker.storageDriver = "zfs";
}
