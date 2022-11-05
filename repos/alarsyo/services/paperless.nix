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

  cfg = config.my.services.paperless;
  my = config.my;
  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
  paperlessDomain = "paperless.${domain}";
in {
  options.my.services.paperless = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Paperless";

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Paperless service";
    };

    passwordFile = mkOption {
      type = types.path;
      description = ''
        Path to a file containing the admin's password
      '';
    };

    secretKeyFile = mkOption {
      type = types.path;
      description = ''
        Path to a file containing the service's secret key
      '';
    };
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      port = cfg.port;
      passwordFile = cfg.passwordFile;
      extraConfig = {
        # Postgres settings
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_DBNAME = "paperless";

        PAPERLESS_ALLOWED_HOSTS = paperlessDomain;
        PAPERLESS_CORS_ALLOWED_HOSTS = "https://${paperlessDomain}";

        PAPERLESS_OCR_LANGUAGE = "fra+eng";
        PAPERLESS_OCR_MODE = "skip_noarchive";

        PAPERLESS_TIME_ZONE = config.time.timeZone;

        PAPERLESS_ADMIN_USER = "alarsyo";
      };
    };

    systemd.services = {
      paperless-scheduler.serviceConfig = {
        EnvironmentFile = cfg.secretKeyFile;
      };

      paperless-consumer.serviceConfig = {
        EnvironmentFile = cfg.secretKeyFile;
      };

      paperless-web.serviceConfig = {
        EnvironmentFile = cfg.secretKeyFile;
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["paperless"];
      ensureUsers = [
        {
          name = "paperless";
          ensurePermissions."DATABASE paperless" = "ALL PRIVILEGES";
        }
      ];
    };

    systemd.services.paperless-server = {
      # Make sure the DB is available
      after = ["postgresql.service"];
    };

    services.nginx.virtualHosts = {
      "${paperlessDomain}" = {
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
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = [paperlessDomain];

    my.services.restic-backup = mkIf cfg.enable {
      paths = [
        config.services.paperless.dataDir
        config.services.paperless.mediaDir
      ];
    };
  };
}
