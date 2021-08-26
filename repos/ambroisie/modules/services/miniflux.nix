# A minimalist, opinionated feed reader
{ config, lib, ... }:
let
  cfg = config.my.services.miniflux;
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

    port = mkOption {
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
        BASE_URL = "https://reader.${config.networking.domain}";
        LISTEN_ADDR = "localhost:${toString cfg.port}";
        # I want fast updates
        POLLING_FREQUENCY = "30";
        BATCH_SIZE = "50";
        # I am a hoarder
        CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
        CLEANUP_ARCHIVE_READ_DAYS = "-1";
      };
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "reader";
        inherit (cfg) port;
      }
    ];
  };
}
