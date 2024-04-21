{pkgs, config, lib, ...}:

lib.mkIf config.services.rtorrent.enable {
  fileSystems."${config.services.rtorrent.downloadDir}" = {
    device = "/media/downloads/TORRENTS";
    fsType = "none";
    options = [ "bind" ];
  };
}
