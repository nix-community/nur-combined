{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "storage" ];
  };
}
