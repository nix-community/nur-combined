{ config, lib, ... }:
let
  cfg = config.my.services.paperless;
in
{
  options.my.services.paperless = with lib; {
    enable = mkEnableOption "Paperless service";

    port = mkOption {
      type = types.port;
      default = 4535;
      example = 8080;
      description = "Internal port for webui";
    };

    secretKeyFile = mkOption {
      type = types.str;
      example = "/var/lib/paperless/secret-key.env";
      description = ''
        Secret key as an 'EnvironmentFile' (see `systemd.exec(5)`)
      '';
    };

    documentPath = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/mnt/paperless";
      description = ''
        Path to the directory to store the documents. Use default if null
      '';
    };

    username = mkOption {
      type = types.str;
      default = "ambroisie";
      example = "username";
      description = "Name of the administrator";
    };

    passwordFile = mkOption {
      type = types.str;
      example = "/var/lib/paperless/password.txt";
      description = "Read the administrator's password from this path";
    };
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;

      port = cfg.port;

      mediaDir = lib.mkIf (cfg.documentPath != null) cfg.documentPath;

      extraConfig =
        let
          paperlessDomain = "paperless.${config.networking.domain}";
        in
        {
          # Use SSO
          PAPERLESS_ENABLE_HTTP_REMOTE_USER = true;
          PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "HTTP_X_USER";

          # Use PostgreSQL
          PAPERLESS_DBHOST = "/run/postgresql";
          PAPERLESS_DBUSER = "paperless";
          PAPERLESS_DBNAME = "paperless";

          # Security settings
          PAPERLESS_ALLOWED_HOSTS = paperlessDomain;
          PAPERLESS_CORS_ALLOWED_HOSTS = "https://${paperlessDomain}";

          # OCR settings
          PAPERLESS_OCR_LANGUAGE = "fra+eng";

          # Misc
          PAPERLESS_TIME_ZONE = config.time.timeZone;
          PAPERLESS_ADMIN_USER = cfg.username;
        };

      # Admin password
      passwordFile = cfg.passwordFile;
    };

    systemd.services = {
      paperless-scheduler = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];

        serviceConfig = {
          EnvironmentFile = cfg.secretKeyFile;
        };
      };

      paperless-consumer = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];

        serviceConfig = {
          EnvironmentFile = cfg.secretKeyFile;
        };
      };

      paperless-web = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];

        serviceConfig = {
          EnvironmentFile = cfg.secretKeyFile;
        };
      };
    };

    # Set-up database
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

    # Set-up media group
    users.groups.media = { };

    users.users.${config.services.paperless.user} = {
      extraGroups = [ "media" ];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "paperless";
        inherit (cfg) port;
        sso = {
          enable = true;
        };

        # Enable websockets on root
        extraConfig = {
          locations."/".proxyWebsockets = true;
        };
      }
    ];

    my.services.backup = {
      paths = [
        config.services.paperless.dataDir
        config.services.paperless.mediaDir
      ];
    };
  };
}
