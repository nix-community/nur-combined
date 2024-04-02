{ config, lib, ... }:
let
  cfg = config.my.services.mealie;
in
{
  options.my.services.mealie = with lib; {
    enable = mkEnableOption "Mealie service";

    port = mkOption {
      type = types.port;
      default = 4537;
      example = 8080;
      description = "Internal port for webui";
    };

    credentialsFile = mkOption {
      type = types.str;
      example = "/var/lib/mealie/credentials.env";
      description = ''
        Configuration file for secrets.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.mealie = {
      enable = true;
      inherit (cfg) port credentialsFile;

      settings = {
        # Basic settings
        BASE_URL = "https://mealie.${config.networking.domain}";
        TZ = config.time.timeZone;
        ALLOw_SIGNUP = "false";

        # Use PostgreSQL
        DB_ENGINE = "postgres";
        POSTGRES_USER = "mealie";
        POSTGRES_PASSWORD = "";
        POSTGRES_SERVER = "/run/postgresql";
        # Pydantic and/or mealie doesn't handle the URI correctly, hijack it
        # with query parameters...
        POSTGRES_DB = "mealie?host=/run/postgresql&dbname=mealie";
      };
    };

    systemd.services = {
      mealie = {
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
      };
    };

    # Set-up database
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "mealie" ];
      ensureUsers = [
        {
          name = "mealie";
          ensureDBOwnership = true;
        }
      ];
    };

    my.services.nginx.virtualHosts = {
      mealie = {
        inherit (cfg) port;

        extraConfig = {
          # Allow bulk upload of recipes for import/export
          locations."/".extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
    };
  };
}
