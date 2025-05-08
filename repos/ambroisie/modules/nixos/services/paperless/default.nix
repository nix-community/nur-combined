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

      settings = {
        # Use SSO
        PAPERLESS_ENABLE_HTTP_REMOTE_USER = true;
        PAPERLESS_ENABLE_HTTP_REMOTE_USER_API = true;
        PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "HTTP_X_USER";

        # Security settings
        PAPERLESS_URL = "https://paperless.${config.networking.domain}";
        PAPERLESS_USE_X_FORWARD_HOST = true;
        PAPERLESS_PROXY_SSL_HEADER = ''["HTTP_X_FORWARDED_PROTO", "https"]'';

        # OCR settings
        PAPERLESS_OCR_LANGUAGE = "fra+eng";

        # Workers
        PAPERLESS_TASK_WORKERS = 3;
        PAPERLESS_THREADS_PER_WORKER = 4;

        # Misc
        PAPERLESS_TIME_ZONE = config.time.timeZone;
        PAPERLESS_ADMIN_USER = cfg.username;
      };

      # Admin password
      passwordFile = cfg.passwordFile;

      # Secret key
      environmentFile = cfg.secretKeyFile;

      # Automatic PostgreSQL provisioning
      database = {
        createLocally = true;
      };
    };

    # Set-up media group
    users.groups.media = { };

    users.users.${config.services.paperless.user} = {
      extraGroups = [ "media" ];
    };

    my.services.nginx.virtualHosts = {
      paperless = {
        inherit (cfg) port;
        sso = {
          enable = true;
        };
        websocketsLocations = [ "/" ];
      };
    };

    my.services.backup = {
      paths = [
        config.services.paperless.dataDir
        config.services.paperless.mediaDir
      ];
    };
  };
}
