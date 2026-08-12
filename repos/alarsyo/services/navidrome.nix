{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    ;

  cfg = config.my.services.navidrome;
  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.navidrome = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Navidrome";
    musicFolder = {
      path = mkOption {
        type = types.str;
        default = "./music";
      };
      backup = mkEnableOption "backup the music folder";
    };
  };

  config = mkIf cfg.enable {
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
      paths = ["/var/lib/navidrome"] ++ optional cfg.musicFolder.backup cfg.musicFolder.path;
      exclude = ["/var/lib/navidrome/cache"];
    };

    services.nginx.virtualHosts."music.${domain}" = {
      forceSSL = true;
      useACMEHost = fqdn;

      listen = [
        # FIXME: hardcoded tailscale IP
        {
          addr = "100.115.172.44";
          port = 443;
          ssl = true;
        }
        {
          addr = "100.115.172.44";
          port = 80;
          ssl = false;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}/";
        proxyWebsockets = true;
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["music.${domain}"];
  };
}
