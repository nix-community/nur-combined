{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ghostfolio;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    types
    ;

  toEnvValue =
    value:
    if lib.isList value then
      builtins.toJSON value
    else if lib.isBool value then
      lib.boolToString value
    else
      toString value;

  listenStream =
    host: port: "${if lib.hasInfix ":" host then "[${host}]" else host}:${toString port}";

  # Ghostfolio does not implement systemd socket activation. This preload adopts
  # the socket passed on fd 3 for the first listen() on $PORT, and only when
  # systemd has set LISTEN_PID to this process.
  socketActivationPreload = pkgs.writeText "ghostfolio-socket-activation.cjs" ''
    const net = require("node:net");

    const { LISTEN_PID, LISTEN_FDS, PORT } = process.env;
    if (LISTEN_PID === String(process.pid) && LISTEN_FDS === "1" && PORT) {
      const listen = net.Server.prototype.listen;
      net.Server.prototype.listen = function (...args) {
        const [first] = args;
        const port = first !== null && typeof first === "object" ? first.port : first;
        if (String(port) !== PORT) return listen.apply(this, args);
        net.Server.prototype.listen = listen;
        const callbacks = args.filter((arg) => typeof arg === "function");
        return listen.call(this, { fd: 3 }, ...callbacks);
      };
    }
  '';
in
{
  imports = [
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "host" ]
      [ "services" "ghostfolio" "settings" "HOST" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "port" ]
      [ "services" "ghostfolio" "settings" "PORT" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "rootUrl" ]
      [ "services" "ghostfolio" "settings" "ROOT_URL" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "logLevels" ]
      [ "services" "ghostfolio" "settings" "LOG_LEVELS" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "database" "url" ]
      [ "services" "ghostfolio" "settings" "DATABASE_URL" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "redis" "host" ]
      [ "services" "ghostfolio" "settings" "REDIS_HOST" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "ghostfolio" "redis" "port" ]
      [ "services" "ghostfolio" "settings" "REDIS_PORT" ]
    )
  ];

  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options.services.ghostfolio = {
    enable = mkEnableOption "Ghostfolio";

    package = lib.mkPackageOption pkgs "ghostfolio" { };

    unixSocket = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/ghostfolio/ghostfolio.sock";
      description = ''
        Unix socket on which Ghostfolio listens, instead of `settings.HOST` and
        `settings.PORT`. `settings.PORT` is still passed to Ghostfolio, which
        uses it to identify the listening socket. systemd creates the socket
        with mode `0660`; override `systemd.sockets.ghostfolio.socketConfig` to
        change its owner or group.
      '';
    };

    autoMigrate = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to run Ghostfolio database migrations before starting the service.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/ghostfolio.env";
      description = ''
        Environment file containing secrets such as `ACCESS_TOKEN_SALT` and
        `JWT_SECRET_KEY`. Values in it override {option}`services.ghostfolio.settings`.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            int
            str
            path
          ]);

        options = {
          HOST = mkOption {
            type = types.str;
            default = "::";
            description = "Host address Ghostfolio listens on.";
          };

          PORT = mkOption {
            type = types.port;
            default = 3333;
            description = "Port Ghostfolio listens on.";
          };

          ROOT_URL = mkOption {
            type = types.str;
            example = "https://wealth.example.com";
            description = "Public root URL of the Ghostfolio instance.";
          };

          LOG_LEVELS = mkOption {
            type = types.listOf (
              types.enum [
                "debug"
                "error"
                "log"
                "verbose"
                "warn"
              ]
            );
            default = [ "warn" ];
            example = [
              "debug"
              "error"
              "log"
              "warn"
            ];
            description = "Ghostfolio log levels.";
          };

          DATABASE_URL = mkOption {
            type = types.str;
            description = ''
              PostgreSQL connection URL. Set automatically when
              {option}`services.ghostfolio.database.createLocally` is enabled.
            '';
          };

          REDIS_HOST = mkOption {
            type = types.str;
            default = "localhost";
            description = "Redis host.";
          };

          REDIS_PORT = mkOption {
            type = types.port;
            default = 6379;
            description = "Redis port.";
          };
        };
      };
      default = { };
      example = {
        REQUEST_TIMEOUT = 200;
      };
      description = ''
        Environment variables passed to Ghostfolio.

        See <https://github.com/ghostfolio/ghostfolio#supported-environment-variables> for available settings.
      '';
    };

    database.createLocally = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to create a local PostgreSQL database and user for Ghostfolio.
      '';
    };

    redis.createLocally = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to create a local Redis instance for Ghostfolio.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null || cfg.settings ? JWT_SECRET_KEY;
        message = ''
          services.ghostfolio requires JWT_SECRET_KEY, usually via
          services.ghostfolio.environmentFile.
        '';
      }
      {
        assertion = cfg.environmentFile != null || cfg.settings ? ACCESS_TOKEN_SALT;
        message = ''
          services.ghostfolio requires ACCESS_TOKEN_SALT, usually via
          services.ghostfolio.environmentFile.
        '';
      }
    ];

    services.ghostfolio.settings.DATABASE_URL = mkIf cfg.database.createLocally "postgresql://ghostfolio@localhost/ghostfolio?host=/run/postgresql";

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "ghostfolio" ];
      ensureUsers = [
        {
          name = "ghostfolio";
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.ghostfolio = mkIf cfg.redis.createLocally {
      enable = true;
      bind = cfg.settings.REDIS_HOST;
      port = cfg.settings.REDIS_PORT;
    };

    systemd.sockets.ghostfolio = {
      description = "Ghostfolio socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [
        (
          if cfg.unixSocket != null then cfg.unixSocket else listenStream cfg.settings.HOST cfg.settings.PORT
        )
      ];
      socketConfig =
        if cfg.unixSocket != null then
          {
            SocketMode = lib.mkDefault "0660";
          }
        else
          {
            # Socket units start before network-online.target, so the address may not exist yet.
            FreeBind = true;
          };
    };

    systemd.services.ghostfolio = {
      description = "Ghostfolio";
      documentation = [ "https://ghostfol.io/" ];

      after = [
        "ghostfolio.socket"
        "network-online.target"
      ]
      ++ optional cfg.database.createLocally "postgresql.service"
      ++ optional cfg.redis.createLocally "redis-ghostfolio.service";

      wants = [ "network-online.target" ];

      requires = [
        "ghostfolio.socket"
      ]
      ++ optional cfg.database.createLocally "postgresql.service"
      ++ optional cfg.redis.createLocally "redis-ghostfolio.service";

      environment = {
        NODE_OPTIONS = "--require ${socketActivationPreload}";
      }
      // lib.mapAttrs (_: toEnvValue) cfg.settings;

      serviceConfig =
        lib.optionalAttrs cfg.autoMigrate {
          ExecStartPre = lib.getExe' cfg.package "ghostfolio-migrate";
        }
        // {
          ExecStart = lib.getExe cfg.package;
          Type = "simple";

          Restart = "on-failure";
          RestartSec = "5s";

          DynamicUser = true;

          EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;

          StateDirectory = "ghostfolio";
          CacheDirectory = "ghostfolio";
          RuntimeDirectory = "ghostfolio";

          # Hardening
          CapabilityBoundingSet = "";
          LockPersonality = true;
          MemoryDenyWriteExecute = false; # Required by V8 JIT
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];
        };
    };
  };
}
