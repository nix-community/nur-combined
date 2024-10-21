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

  # FIXME(NixOS 24.11) Copy pasted from nixpkgs master module, because some needed changes weren't in stable yet.
  config = mkIf cfg.enable (let
    settings = {
      ALLOW_SIGNUP = "false";
      BASE_URL = "https://mealie.${domain}";
      TZ = config.time.timeZone;

      # Use PostgreSQL
      DB_ENGINE = "postgres";

      # Settings for Mealie 1.7+
      POSTGRES_URL_OVERRIDE = "postgresql://mealie:@/mealie?host=/run/postgresql";
    };
  in {
    systemd.services = {
      mealie = {
        after = ["network-online.target" "postgresql.service"];
        requires = ["postgresql.service"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        description = "Mealie, a self hosted recipe manager and meal planner";

        environment =
          {
            PRODUCTION = "true";
            API_PORT = toString cfg.port;
            BASE_URL = "http://localhost:${toString cfg.port}";
            DATA_DIR = "/var/lib/mealie";
            CRF_MODEL_PATH = "/var/lib/mealie/model.crfmodel";
          }
          // (builtins.mapAttrs (_: val: toString val) settings);

        serviceConfig = {
          DynamicUser = true;
          User = "mealie";
          ExecStartPre = "${pkg}/libexec/init_db";
          ExecStart = "${lib.getExe pkg} -b ${listenAddress}:${builtins.toString cfg.port}";
          EnvironmentFile = lib.mkIf (cfg.credentialsFile != null) cfg.credentialsFile;
          StateDirectory = "mealie";
          StandardOutput = "journal";
        };
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
  });
}
