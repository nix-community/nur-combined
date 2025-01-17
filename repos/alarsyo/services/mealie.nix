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
  pkg = pkgs.unstable.mealie;
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
  };

  config = mkIf cfg.enable {
    services.mealie = {
      inherit listenAddress;

      enable = true;
      package = pkgs.unstable.mealie;
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
