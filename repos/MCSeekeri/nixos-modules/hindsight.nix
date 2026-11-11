{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hindsight;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  pg0 = pkgs.callPackage ../pkgs/pg0 { };
  pg0-embedded = pkgs.python3Packages.callPackage ../pkgs/pg0-embedded { inherit pg0; };

  databaseUrl =
    if cfg.database.mode == "local" then
      "postgresql://${cfg.user}@/${cfg.database.name}?host=/run/postgresql"
    else if cfg.database.mode == "external" then
      cfg.database.url
    else
      "pg0://${cfg.database.pg0Name}";

  baseEnvironment = {
    HOME = "/var/lib/hindsight";
    HINDSIGHT_API_DATABASE_URL = databaseUrl;
  }
  // lib.optionalAttrs (cfg.database.mode == "pg0") {
    PG0_HOME = "/var/lib/hindsight/.pg0";
    PYTHONPATH = "${pg0-embedded}/${pkgs.python3.sitePackages}";
  };

  environment = baseEnvironment // cfg.settings;

  environmentList = lib.mapAttrsToList (
    name: value:
    "${name}=${if lib.isBool value then (if value then "true" else "false") else toString value}"
  ) environment;

  localDatabase = cfg.database.mode == "local";
  createExtension = localDatabase && cfg.database.createExtension;
in
{
  meta.maintainers = [ lib.maintainers.MCSeekeri ];

  options.services.hindsight = {
    enable = mkEnableOption "Hindsight API server";

    package = lib.mkPackageOption pkgs "hindsight-api-slim" { };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address the Hindsight API listens on.";
    };

    port = mkOption {
      type = types.port;
      default = 8888;
      description = "Port the Hindsight API listens on.";
    };

    workers = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "Number of uvicorn worker processes.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the API port in the firewall.";
    };

    user = mkOption {
      type = types.str;
      default = "hindsight";
      description = ''
        User the service runs as. With the default local database this user is
        also created as a PostgreSQL role and owns the database.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "hindsight";
      description = "Group the service runs as.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/hindsight.env";
      description = ''
        File with additional environment variables, usually API keys such as
        `HINDSIGHT_API_LLM_API_KEY`. Format: `KEY=value` lines.
      '';
    };

    settings = mkOption {
      type = types.attrsOf (
        types.oneOf [
          types.str
          types.int
          types.bool
        ]
      );
      default = { };
      example = {
        HINDSIGHT_API_LLM_PROVIDER = "openai";
        HINDSIGHT_API_EMBEDDINGS_PROVIDER = "openai";
        HINDSIGHT_API_RERANKER_PROVIDER = "rrf";
      };
      description = ''
        Extra environment variables for the Hindsight API. Values are passed
        through as-is; use the upstream `HINDSIGHT_API_*` variable names.
      '';
    };

    database = {
      mode = mkOption {
        type = types.enum [
          "local"
          "external"
          "pg0"
        ];
        default = "local";
        description = ''
          Database backend:

          - `local`: let this module manage a local PostgreSQL instance with
            the pgvector extension.
          - `external`: connect to an existing PostgreSQL server; set
            {option}`services.hindsight.database.url`.
          - `pg0`: use the pg0 embedded PostgreSQL from this repository.
        '';
      };

      name = mkOption {
        type = types.str;
        default = "hindsight";
        description = "Database name used by the `local` backend.";
      };

      url = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "postgresql://hindsight@db.example.com/hindsight";
        description = ''
          PostgreSQL connection URL. Required when
          {option}`services.hindsight.database.mode` is `external`.
        '';
      };

      pg0Name = mkOption {
        type = types.str;
        default = "hindsight";
        description = "pg0 instance name used by the `pg0` backend.";
      };

      createExtension = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Create the `vector` extension in the local database. The initial
          database migration needs it before Hindsight creates its tables.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.mode != "external" || cfg.database.url != null;
        message = "services.hindsight.database.url must be set when database.mode is \"external\".";
      }
    ];

    users.users.${cfg.user} = mkIf (cfg.user == "hindsight") {
      isSystemUser = true;
      inherit (cfg) group;
      home = "/var/lib/hindsight";
      createHome = false;
    };
    users.groups.${cfg.group} = mkIf (cfg.group == "hindsight") { };

    services.postgresql = mkIf localDatabase {
      enable = true;
      extensions = lib.mkAfter [ (ps: [ ps.pgvector ]) ];
      ensureDatabases = lib.mkAfter [ cfg.database.name ];
      ensureUsers = lib.mkAfter [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
    };

    # PostgreSQL extensions are installed per database and pgvector is not a
    # trusted extension, so a one-shot superuser job creates it before the
    # service starts.
    systemd.services.hindsight-db-init = mkIf createExtension {
      description = "Create the pgvector extension for Hindsight";
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        ExecStart = "${config.services.postgresql.package}/bin/psql -d ${cfg.database.name} -c 'CREATE EXTENSION IF NOT EXISTS vector'";
        RemainAfterExit = true;
      };
    };

    systemd.services.hindsight = {
      description = "Hindsight API server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ]
      ++ lib.optional localDatabase "postgresql.service"
      ++ lib.optional createExtension "hindsight-db-init.service";
      requires =
        lib.optional localDatabase "postgresql.service"
        ++ lib.optional createExtension "hindsight-db-init.service";
      path = [ pkgs.procps ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/hindsight-api --host ${cfg.host} --port ${toString cfg.port} --workers ${toString cfg.workers}";
        Environment = environmentList;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        WorkingDirectory = "/var/lib/hindsight";
        StateDirectory = "hindsight";
        StateDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStopSec = 30;
        UMask = "0077";

        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = [ ];
        KeyringMode = "private";
        LockPersonality = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [
          "@system-service"
          "@aio"
          "@ipc"
          "~@debug"
          "~@mount"
          "~@raw-io"
          "~@reboot"
          "~@swap"
          "~@obsolete"
          "~@cpu-emulation"
        ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
