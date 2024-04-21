{ pkgs, config, lib, ...}:

lib.mkIf config.services.rtorrent.enable {
  services.rtorrent = {
    downloadDir = "${config.services.rtorrent.dataDir}/Downloads";
  };
}
