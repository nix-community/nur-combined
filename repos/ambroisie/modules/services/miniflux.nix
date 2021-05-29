# A minimalist, opinionated feed reader
{ config, lib, ... }:
let
  cfg = config.my.services.miniflux;

  domain = config.networking.domain;
  minifluxDomain = "reader.${config.networking.domain}";
in
{
  options.my.services.miniflux = with lib; {
    enable = mkEnableOption "Miniflux feed reader";

    username = mkOption {
      type = types.str;
      default = "Ambroisie";
      example = "username";
      description = "Name of the admin user";
    };

    password = mkOption {
      type = types.str;
      example = "password";
      description = "Password of the admin user";
    };

    privatePort = mkOption {
      type = types.port;
      default = 9876;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    # The service automatically sets up the DB
    services.miniflux = {
      enable = true;

      adminCredentialsFile =
        # Insecure, I don't care.
        builtins.toFile "credentials.env" ''
          ADMIN_USERNAME=${cfg.username}
          ADMIN_PASSWORD=${cfg.password}
        '';

      config = {
        # Virtual hosts settings
        BASE_URL = "https://${minifluxDomain}";
        LISTEN_ADDR = "localhost:${toString cfg.privatePort}";
        # I want fast updates
        POLLING_FREQUENCY = "30";
        BATCH_SIZE = "50";
        # I am a hoarder
        CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
        CLEANUP_ARCHIVE_READ_DAYS = "-1";
      };
    };

    # Proxy to Jellyfin
    services.nginx.virtualHosts."${minifluxDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.privatePort}/";
    };
  };
}
