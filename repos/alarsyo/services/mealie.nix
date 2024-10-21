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
    ;

  cfg = config.my.services.mealie;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.mealie = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Mealie";
    port = mkOption {
      type = types.port;
      example = 8080;
      description = "Internal port for Mealie webapp";
    };
  };

  config = mkIf cfg.enable {
    services.mealie = {
      enable = true;
      package = pkgs.unstable.mealie;
      listenAddress = "127.0.0.1";
      port = cfg.port;

      settings = {
        ALLOW_SIGNUP = "false";
        BASE_URL = "https://mealie.${domain}";
        TZ = config.time.timeZone;

        # Use PostgreSQL
        DB_ENGINE = "postgres";

        # Settings for Mealie 1.2
        #POSTGRES_USER = "mealie";
        #POSTGRES_PASSWORD = "";
        #POSTGRES_SERVER = "/run/postgresql";
        ## Pydantic and/or mealie doesn't handle the URI correctly, hijack it
        ## with query parameters...
        #POSTGRES_DB = "mealie?host=/run/postgresql&dbname=mealie";

        # Settings for Mealie 1.7+, when that gets into NixOS stable
        POSTGRES_URL_OVERRIDE = "postgresql://mealie:@/mealie?host=/run/postgresql";
      };
    };

    systemd.services = {
      mealie = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
      };
    };

    # Set-up database
    services.postgresql = {
      enable = true;
      ensureDatabases = ["mealie"];
      ensureUsers = [
        {
          name = "mealie";
          ensureDBOwnership = true;
        }
      ];
    };

    services.postgresqlBackup = {
      databases = ["mealie"];
    };

    services.nginx.virtualHosts."mealie.${domain}" = {
      forceSSL = true;
      useACMEHost = fqdn;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["mealie.${domain}"];

    my.services.restic-backup = {
      paths = ["/var/lib/mealie"];
    };
  };
}
