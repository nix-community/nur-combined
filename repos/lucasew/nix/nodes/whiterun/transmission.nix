{ pkgs, config, lib, ...}:

lib.mkIf config.services.transmission.enable {
  fileSystems."/var/lib/transmission/Downloads" = {
    device = "/media/downloads/TORRENTS";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/transmission/.incomplete" = {
    device = "/media/downloads/TORRENTS/.incomplete";
    fsType = "none";
    options = [ "bind" ];
  };
}
