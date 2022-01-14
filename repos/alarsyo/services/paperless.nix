{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
  ;

  cfg = config.my.services.paperless;
  my = config.my;
  domain = config.networking.domain;
  paperlessDomain = "paperless.${domain}";
  secretKeyFile = pkgs.writeText "paperless-secret-key-file.env" my.secrets.paperless.secretKey;
in
{
  options.my.services.paperless = let inherit (lib) types; in {
    enable = mkEnableOption "Paperless";

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Internal port for Paperless service";
    };
  };

  config = mkIf cfg.enable {
    services.paperless-ng = {
      enable = true;
      port = cfg.port;
      passwordFile = pkgs.writeText "paperless-password-file.txt" config.my.secrets.paperless.adminPassword;
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

        # FIXME: upstream module should be fixed instead of setting the redis URL myself
        PAPERLESS_REDIS = "unix://${config.services.redis.servers.paperless.unixSocket}";
      };
    };

    systemd.services = {
      paperless-ng-server.serviceConfig = {
        EnvironmentFile = secretKeyFile;
        BindReadOnlyPaths = [ config.services.redis.servers.paperless.unixSocket ];
      };

      paperless-ng-consumer.serviceConfig = {
        EnvironmentFile = secretKeyFile;
        BindReadOnlyPaths = [ config.services.redis.servers.paperless.unixSocket ];
      };

      paperless-ng-web.serviceConfig = {
        EnvironmentFile = secretKeyFile;
        BindReadOnlyPaths = [ config.services.redis.servers.paperless.unixSocket ];
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "paperless" ];
      ensureUsers = [
        {
          name = "paperless";
          ensurePermissions."DATABASE paperless" = "ALL PRIVILEGES";
        }
      ];
    };

    services.redis.servers.paperless.enable = true;

    systemd.services.paperless-ng-server = {
      # Make sure the DB is available
      after = [ "postgresql.service" "redis-paperless.service" ];
    };

    services.nginx.virtualHosts = {
      "${paperlessDomain}" = {
        forceSSL = true;
        useACMEHost = domain;

        listen = [
          # FIXME: hardcoded tailscale IP
          {
            addr = "100.80.61.67";
            port = 443;
            ssl = true;
          }
          {
            addr = "100.80.61.67";
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

    users.users.${config.services.paperless-ng.user} = {
      extraGroups = [ config.services.redis.servers.paperless.user ];
    };

    my.services.restic-backup = mkIf cfg.enable {
      paths = [
        config.services.paperless-ng.dataDir
        config.services.paperless-ng.mediaDir
      ];
    };
  };
}
