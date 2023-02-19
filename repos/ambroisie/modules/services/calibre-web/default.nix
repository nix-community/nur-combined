{ config, lib, ... }:
let
  cfg = config.my.services.calibre-web;
in
{
  options.my.services.calibre-web = with lib; {
    enable = mkEnableOption "Calibre-web server";

    port = mkOption {
      type = types.port;
      default = 8083;
      example = 8080;
      description = "Internal port for webui";
    };

    libraryPath = mkOption {
      type = with types; either path str;
      example = /data/media/library;
      description = "Path to the Calibre library to use";
    };
  };

  config = lib.mkIf cfg.enable {
    services.calibre-web = {
      enable = true;

      listen = {
        ip = "127.0.0.1";
        port = cfg.port;
      };

      group = "media";

      options = {
        calibreLibrary = cfg.libraryPath;
        enableBookConversion = true;
      };
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "library";
        inherit (cfg) port;
      }
    ];

    my.services.backup = {
      paths = [
        "/var/lib/${config.services.calibre-web.dataDir}" # For `app.db` and `gdrive.db`
        cfg.libraryPath
      ];
    };

    services.fail2ban.jails = {
      calibre-web = ''
        enabled = true
        filter = calibre-web
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/calibre-web.conf".text = ''
        [Definition]
        failregex = ^.*Login failed for user ".*" IP-address: <HOST>$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=calibre-web.service
      '';
    };
  };
}
