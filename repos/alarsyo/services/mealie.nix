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
  listenAddress = "127.0.0.1";
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
    credentialsFile = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/mealie-credentials.env";
      description = ''
        File containing credentials used in mealie such as {env}`POSTGRES_PASSWORD`
        or sensitive LDAP options.

        Expects the format of an `EnvironmentFile=`, as described by {manpage}`systemd.exec(5)`.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.mealie = {
      inherit listenAddress;
      inherit (cfg) credentialsFile;

      enable = true;
      package = pkgs.mealie;
      port = cfg.port;

      settings = {
        ALLOW_SIGNUP = "false";
        BASE_URL = "https://mealie.${domain}";
        TZ = config.time.timeZone;
        DB_ENGINE = "postgres";
        POSTGRES_URL_OVERRIDE = "postgresql://mealie:@/mealie?host=/run/postgresql";
      };
    };

    systemd.services.mealie = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
      serviceConfig = {
        TimeoutStartSec = 600;
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
        proxyPass = "http://${listenAddress}:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["mealie.${domain}"];

    my.services.restic-backup = {
      paths = ["/var/lib/mealie"];
    };
  };
}
