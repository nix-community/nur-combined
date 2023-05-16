{ ... }:

{
  boot.zfs.allowHibernation = true;
  boot.zfs.forceImportRoot = false;
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "zroot" ];
  };
}
