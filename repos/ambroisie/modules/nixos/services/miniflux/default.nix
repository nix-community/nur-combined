# A minimalist, opinionated feed reader
{ config, lib, ... }:
let
  cfg = config.my.services.miniflux;
in
{
  options.my.services.miniflux = with lib; {
    enable = mkEnableOption "Miniflux feed reader";

    credentialsFiles = mkOption {
      type = types.str;
      example = "/var/lib/miniflux/creds.env";
      description = ''
        Credential file as an 'EnvironmentFile' (see `systemd.exec(5)`)
      '';
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

      adminCredentialsFile = cfg.credentialsFiles;

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

    my.services.nginx.virtualHosts = {
      reader = {
        inherit (cfg) port;
      };
    };
  };
}
