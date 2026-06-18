{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    boolToString
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    optionalAttrs
    types
    ;

  cfg = config.services.shlink;
  db = cfg.database;

  effectiveDriver = if db.createLocally then "postgres" else db.driver;
  shlinkPackage = cfg.package.override {
    withPostgresql = effectiveDriver == "postgres";
    withMysql = effectiveDriver == "mysql" || effectiveDriver == "maria";
    withSqlite = effectiveDriver == "sqlite";
    withMssql = effectiveDriver == "mssql";
  };

  shlinkRoot = "${shlinkPackage}/share/php/shlink";

  bindPrivileged = cfg.settings.PORT < 1024;

  toEnvValue = value: if lib.isBool value then boolToString value else toString value;
in
{
  options.services.shlink = {
    enable = mkEnableOption "Shlink URL shortener";

    package = mkPackageOption pkgs "shlink" { } // { };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the configured Shlink port in the firewall.";
    };

    environmentFiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "/run/secrets/shlink.env" ];
      description = ''
        Additional systemd `EnvironmentFile` entries.

        Use this for values that should not be represented directly in
        the Nix store.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType =
          with types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
        options = {
          PORT = mkOption {
            type = types.port;
            default = 8080;
          };
        };
      };
      default = { };
      example = {
        BASE_PATH = "/shlink";
        DEFAULT_SHORT_CODES_LENGTH = 6;
        ANONYMIZE_REMOTE_ADDR = true;
        GEOLITE_LICENSE_KEY_FILE = "/run/secrets/shlink-geolite";
        INITIAL_API_KEY_FILE = "/run/secrets/shlink-initial-api-key";
      };
      description = ''
        Environment variables passed to Shlink.
      '';
    };

    database = {
      createLocally = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to create and use a local PostgreSQL database through
          `services.postgresql`.
        '';
      };

      driver = mkOption {
        type = types.enum [
          "postgres"
          "mysql"
          "maria"
          "mssql"
          "sqlite"
        ];
        default = "postgres";
        description = ''
          Database driver used by Shlink.

          Ignored when `createLocally` is true, in which case PostgreSQL is
          used.
        '';
      };

      name = mkOption {
        type = types.str;
        default = "shlink";
        description = "Database name.";
      };

      user = mkOption {
        type = types.str;
        default = "shlink";
        description = "Database user.";
      };

      host = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "db.example.org";
        description = ''
          External database host.

          Required when `createLocally` is false and `driver` is not
          `sqlite`, unless `DB_HOST` or `DB_UNIX_SOCKET` is provided via
          `settings`.
        '';
      };

      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "External database port.";
      };

      passwordFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/secrets/shlink-db-password";
        description = ''
          File containing the external database password.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          db.createLocally
          || db.driver == "sqlite"
          || db.host != null
          || cfg.settings ? DB_HOST
          || cfg.settings ? DB_UNIX_SOCKET;
        message = ''
          services.shlink.database.host must be set when using an external
          non-SQLite database, unless DB_HOST or DB_UNIX_SOCKET is provided
          via services.shlink.settings.
        '';
      }
    ];

    services.shlink = {
      settings = {
        SHLINK_RUNTIME = "rr";

        SHLINK_DATA_DIR = "/var/lib/shlink";
        SHLINK_CACHE_DIR = "/var/cache/shlink";
        SHLINK_RUNTIME_DIR = "/run/shlink";
        SHLINK_LOG_DIR = "/var/log/shlink";
        SHLINK_GEOLITE_DB_PATH = mkDefault "/var/lib/shlink/GeoLite2-City.mmdb";

        ADDRESS = mkDefault "127.0.0.1";

        LOGS_FORMAT = mkDefault "console";
        SKIP_INITIAL_GEOLITE_DOWNLOAD = mkDefault false;
      }
      // (
        if db.createLocally then
          {
            DB_DRIVER = "postgres";
            DB_NAME = db.name;
            DB_USER = db.user;
            DB_UNIX_SOCKET = "/run/postgresql";
          }
        else if db.driver == "sqlite" then
          {
            DB_DRIVER = "sqlite";
          }
        else
          {
            DB_DRIVER = db.driver;
            DB_NAME = db.name;
            DB_USER = db.user;
          }
          // optionalAttrs (db.host != null) {
            DB_HOST = db.host;
          }
          // optionalAttrs (db.port != null) {
            DB_PORT = db.port;
          }
          // optionalAttrs (db.passwordFile != null) {
            DB_PASSWORD_FILE = db.passwordFile;
          }
      );
    };

    services.postgresql = mkIf db.createLocally {
      enable = true;
      ensureDatabases = [ db.name ];
      ensureUsers = [
        {
          name = db.user;
          ensureDBOwnership = true;
        }
      ];
    };

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.settings.PORT;

    systemd.services.shlink = {
      description = "Shlink URL shortener";
      wantedBy = [ "multi-user.target" ];

      after = [
        "network-online.target"
      ]
      ++ optional db.createLocally "postgresql.service";

      wants = [
        "network-online.target"
      ]
      ++ optional db.createLocally "postgresql.service";

      requires = optional db.createLocally "postgresql.service";

      environment = lib.mapAttrs (_: toEnvValue) cfg.settings;
      path = [ shlinkPackage.php ];

      preStart = ''
        set -euo pipefail

        mkdir -p \
          "$SHLINK_DATA_DIR" \
          "$SHLINK_CACHE_DIR" \
          "$SHLINK_RUNTIME_DIR" \
          "$SHLINK_LOG_DIR" \
          "$(dirname "$SHLINK_GEOLITE_DB_PATH")"

        flags=(
          --no-interaction
          --clear-db-cache
        )

        # Read through Shlink so *_FILE fallback logic is honoured.
        geolite_license_key="$(${lib.getExe shlinkPackage} env-var:read GEOLITE_LICENSE_KEY || true)"
        skip_initial_geolite_download="$(${lib.getExe shlinkPackage} env-var:read SKIP_INITIAL_GEOLITE_DOWNLOAD || true)"
        initial_api_key="$(${lib.getExe shlinkPackage} env-var:read INITIAL_API_KEY || true)"

        if [[ -z "$geolite_license_key" || "$skip_initial_geolite_download" == "true" ]]; then
          flags+=(--skip-download-geolite)
        fi

        if [[ -n "$initial_api_key" ]]; then
          flags+=("--initial-api-key=$initial_api_key")
        fi

        ${shlinkRoot}/vendor/bin/shlink-installer init "''${flags[@]}"
      '';

      serviceConfig = {
        Type = "notify";
        User = "shlink";
        Group = "shlink";
        DynamicUser = true;

        WorkingDirectory = shlinkRoot;

        ExecStart = "${lib.getExe pkgs.roadrunner} serve -c ${shlinkRoot}/config/roadrunner/.rr.yml";
        EnvironmentFile = cfg.environmentFiles;

        ReadWritePaths = lib.optional db.createLocally "/run/postgresql";

        StateDirectory = "shlink";
        CacheDirectory = "shlink";
        RuntimeDirectory = "shlink";
        LogsDirectory = "shlink";

        StateDirectoryMode = "0700";
        CacheDirectoryMode = "0700";
        RuntimeDirectoryMode = "0700";
        LogsDirectoryMode = "0700";

        KillMode = "mixed";
        Restart = "always";
        RestartSec = 5;
        TimeoutStopSec = 30;

        AmbientCapabilities = if bindPrivileged then "CAP_NET_BIND_SERVICE" else "";
        CapabilityBoundingSet = if bindPrivileged then "CAP_NET_BIND_SERVICE" else "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = !bindPrivileged;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        UMask = "0077";
      };
    };
  };
}
