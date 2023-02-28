{ ... }:

# syncing to backup zpool
#   syncoid storage/vmiso archive/downloads/vmiso
#   syncoid storage/backup-hdexterno archive/backup-hdexterno
#   syncoid zroot/vms archive/vms -r

{
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "storage" "zroot" ];
  };
  boot.zfs = {
    forceImportRoot = false;
    requestEncryptionCredentials = [ "zroot" ];
    allowHibernation = true;
    extraPools = [ "storage" ];
  };
  virtualisation.docker.storageDriver = "zfs";
  systemd.services.docker-jellyfin.after = [ "zfs-import-storage.service" ];
  systemd.services.transmission.after = [ "zfs-import-storage.service" ];
}
