{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.navidrome;
  domain = config.networking.domain;
in {
  options.my.services.navidrome = {
    enable = mkEnableOption "Navidrome";
    musicFolder = {
      path = mkOption {
        type = types.str;
        default = "./music";
      };
      backup = mkEnableOption "backup the music folder";
    };
  };

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        Port = 4533;
        LastFM.Enabled = false;
        MusicFolder = cfg.musicFolder.path;
      };
    };

    my.services.restic-backup = {
      paths = [ "/var/lib/navidrome" ] ++ optional cfg.musicFolder.backup cfg.musicFolder.path;
      exclude = [ "/var/lib/navidrome/cache" ];
    };

    services.nginx.virtualHosts."music.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;

      listen = [
        # FIXME: hardcoded tailscale IP
        {
          addr = "100.80.61.67";
          port = 443;
          ssl = true;
        }
        {
          addr = "100.80.61.67";
          port = 80;
          ssl = false;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}/";
        proxyWebsockets = true;
      };
    };
  };
}
