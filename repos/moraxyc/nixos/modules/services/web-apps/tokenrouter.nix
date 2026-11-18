{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tokenrouter;
  format = pkgs.formats.yaml { };
  configFile = format.generate "tokenrouter-config.yaml" cfg.settings;

  listenAddress =
    host: port:
    let
      connectHost =
        if host == "0.0.0.0" then
          "127.0.0.1"
        else if host == "::" then
          "::1"
        else
          host;
    in
    "${if lib.hasInfix ":" connectHost then "[${connectHost}]" else connectHost}:${toString port}";

  # systemd cannot parse hostnames in ListenStream, so map localhost to loopback.
  socketHost =
    if cfg.settings.server.host == "localhost" then "127.0.0.1" else cfg.settings.server.host;
  tcpListenStream = "${
    if lib.hasInfix ":" socketHost then "[${socketHost}]" else socketHost
  }:${toString cfg.settings.server.port}";
  isUnixHost = lib.hasPrefix "/" cfg.settings.server.host;
  useSocket = cfg.socketActivation || cfg.unixSocket != null;
  useUnixSocket = cfg.unixSocket != null || isUnixHost;
  socketPath = if cfg.unixSocket != null then cfg.unixSocket else cfg.settings.server.host;

  postgresqlPackage =
    if cfg.database.createLocally then config.services.postgresql.package else pkgs.postgresql;
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options.services.tokenrouter = {
    enable = lib.mkEnableOption "TokenRouter, an open source unified LLM gateway";

    package = lib.mkPackageOption pkgs "tokenrouter" { };

    socketActivation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to use systemd socket activation for the TokenRouter web server.

        systemd binds the listening socket and passes it to TokenRouter. This
        requires the patched tokenrouter package from this repository.
      '';
    };

    unixSocket = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/tokenrouter/tokenrouter.sock";
      description = ''
        Unix socket on which TokenRouter listens, instead of
        {option}`services.tokenrouter.settings.server.host` and
        {option}`services.tokenrouter.settings.server.port`. Implies
        {option}`services.tokenrouter.socketActivation`. systemd creates the
        socket with mode `0660`; when
        {option}`services.tokenrouter.configureNginx` is enabled its group is
        set to nginx's group. Override
        `systemd.sockets.tokenrouter.socketConfig` to change the permissions.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the TokenRouter port in the firewall.";
    };

    configureNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to configure nginx as a reverse proxy for TokenRouter.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "router.example.org";
      description = "Domain name for the nginx virtual host.";
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/tokenrouter.env";
      description = ''
        Environment file read by systemd. It can contain secrets referenced via
        `''${VAR}` in {option}`services.tokenrouter.settings` (such as
        `DATABASE_PASSWORD`, `REDIS_PASSWORD`, or `TOKENROUTER_SECRET_ENCRYPTION_KEY`)
        as well as first-boot `AUTO_SETUP`, `ADMIN_EMAIL`, and `ADMIN_PASSWORD`.
      '';
    };

    initialAdmin = {
      email = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "admin@example.org";
        description = ''
          Initial administrator email address. When set and TokenRouter has not
          been initialized yet, unattended first-boot setup (`AUTO_SETUP=true`)
          is enabled automatically.
        '';
      };

      passwordFile = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        example = "/run/secrets/tokenrouter-admin-password";
        description = ''
          File containing the initial administrator password, loaded via systemd
          `LoadCredential`. If omitted while {option}`initialAdmin.email` is
          set, TokenRouter generates a one-time random password on first startup
          and prints it to the journal.
        '';
      };
    };

    database = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to configure a local PostgreSQL database and user for
          TokenRouter.
        '';
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "tokenrouter";
        description = "PostgreSQL database name.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "tokenrouter";
        description = "PostgreSQL database user.";
      };
    };

    redis = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to configure a local Redis instance for TokenRouter over a
          Unix socket.
        '';
      };
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;

        options = {
          config_version = lib.mkOption {
            type = lib.types.int;
            default = 2;
            readOnly = true;
            description = "TokenRouter configuration schema version.";
          };

          timezone = lib.mkOption {
            type = lib.types.str;
            default = if config.time.timeZone != null then config.time.timeZone else "Asia/Shanghai";
            defaultText = lib.literalExpression ''
              if config.time.timeZone != null then config.time.timeZone else "Asia/Shanghai"
            '';
            description = "Application calendar timezone.";
          };

          server = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                host = lib.mkOption {
                  type = lib.types.str;
                  default = "127.0.0.1";
                  example = "0.0.0.0";
                  description = "Address on which TokenRouter listens.";
                };

                port = lib.mkOption {
                  type = lib.types.port;
                  default = 8080;
                  description = "TCP port on which TokenRouter listens.";
                };

                mode = lib.mkOption {
                  type = lib.types.enum [
                    "release"
                    "debug"
                  ];
                  default = "release";
                  description = "Gin server mode.";
                };
              };
            };
            default = { };
            description = "HTTP server configuration.";
          };

          storage = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                dir = lib.mkOption {
                  type = lib.types.str;
                  default = "/var/lib/tokenrouter/data";
                  description = "Application data directory.";
                };
              };
            };
            default = { };
            description = "Storage configuration.";
          };

          log = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                output = lib.mkOption {
                  type = lib.types.submodule {
                    freeformType = format.type;
                    options = {
                      to_stdout = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "Write logs to stdout for journald collection.";
                      };

                      to_file = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Write logs to a file under the data directory.";
                      };
                    };
                  };
                  default = { };
                  description = "Log output destinations.";
                };
              };
            };
            default = { };
            description = "Logging configuration.";
          };

          database = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                host = lib.mkOption {
                  type = lib.types.str;
                  default = "localhost";
                  example = "db.example.org";
                  description = "PostgreSQL host or Unix socket directory.";
                };

                port = lib.mkOption {
                  type = lib.types.port;
                  default = 5432;
                  description = "PostgreSQL port.";
                };

                user = lib.mkOption {
                  type = lib.types.str;
                  default = "tokenrouter";
                  description = "PostgreSQL username.";
                };

                dbname = lib.mkOption {
                  type = lib.types.str;
                  default = "tokenrouter";
                  description = "PostgreSQL database name.";
                };

                sslmode = lib.mkOption {
                  type = lib.types.str;
                  default = "prefer";
                  description = "PostgreSQL SSL mode.";
                };
              };
            };
            default = { };
            description = "PostgreSQL configuration.";
          };

          redis = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                host = lib.mkOption {
                  type = lib.types.str;
                  default = "127.0.0.1";
                  description = "Redis host or Unix socket path.";
                };

                port = lib.mkOption {
                  type = lib.types.int;
                  default = 6379;
                  description = "Redis TCP port (ignored when `host` is a Unix socket path).";
                };

                db = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "Redis database number.";
                };

                enable_tls = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Whether to enable TLS for Redis connections.";
                };
              };
            };
            default = { };
            description = "Redis configuration.";
          };

          security = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                secret_encryption_key = lib.mkOption {
                  type = lib.types.str;
                  default = "\${TOKENROUTER_SECRET_ENCRYPTION_KEY}";
                  description = ''
                    Hex encryption key for stored credentials and TOTP. Defaults
                    to an environment reference automatically generated and
                    persisted in `/var/lib/tokenrouter` when unset.
                  '';
                };
              };
            };
            default = { };
            description = "Security configuration.";
          };
        };
      };
      default = { };
      example = {
        site.frontend_url = "https://router.example.org";
        server.client_ip.trust_forwarded_headers = true;
        database.password = "\${DATABASE_PASSWORD}";
      };
      description = ''
        Configuration written to TokenRouter's YAML configuration file
        (`config_version: 2`). Supports explicit `''${VAR}` references resolved
        from {option}`services.tokenrouter.environmentFile`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tokenrouter.settings = {
      database = lib.mkIf cfg.database.createLocally {
        host = "/run/postgresql";
        port = config.services.postgresql.settings.port;
        user = cfg.database.user;
        dbname = cfg.database.name;
        sslmode = "disable";
      };

      redis = lib.mkIf cfg.redis.createLocally {
        host = config.services.redis.servers.tokenrouter.unixSocket;
        port = config.services.redis.servers.tokenrouter.port;
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional (
      cfg.openFirewall && !useUnixSocket
    ) cfg.settings.server.port;

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.tokenrouter = lib.mkIf cfg.redis.createLocally {
      enable = true;
    };

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass =
            if useUnixSocket then
              "http://unix:${socketPath}"
            else
              "http://${listenAddress cfg.settings.server.host cfg.settings.server.port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 256m;
            proxy_buffering off;
            proxy_read_timeout 600s;
          '';
        };
      };
    };

    systemd.sockets.tokenrouter = lib.mkIf useSocket {
      description = "TokenRouter socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [
        (if useUnixSocket then socketPath else tcpListenStream)
      ];
      socketConfig =
        if useUnixSocket then
          {
            SocketMode = lib.mkDefault "0660";
            SocketGroup = lib.mkIf cfg.configureNginx (lib.mkDefault config.services.nginx.group);
          }
        else
          {
            # Socket units start before network-online.target, so the address may not exist yet.
            FreeBind = true;
          };
    };

    systemd.services.tokenrouter = {
      description = "TokenRouter AI API Gateway";
      documentation = [ "https://github.com/TokenFlux/TokenRouter" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
      ]
      ++ lib.optional useSocket "tokenrouter.socket"
      ++ lib.optional cfg.database.createLocally "postgresql.service"
      ++ lib.optional cfg.redis.createLocally "redis-tokenrouter.service";
      requires =
        lib.optional useSocket "tokenrouter.socket"
        ++ lib.optional cfg.database.createLocally "postgresql.service"
        ++ lib.optional cfg.redis.createLocally "redis-tokenrouter.service";

      path = [ postgresqlPackage ];

      environment = {
        DATA_DIR = "/var/lib/tokenrouter";
        GIN_MODE = cfg.settings.server.mode;
      }
      // lib.optionalAttrs (cfg.initialAdmin.email != null) {
        AUTO_SETUP = "true";
        ADMIN_EMAIL = cfg.initialAdmin.email;
      };

      script = ''
        if [ -z "''${TOKENROUTER_SECRET_ENCRYPTION_KEY:-}" ]; then
          key_file="/var/lib/tokenrouter/.secret-encryption-key"
          if [ ! -s "$key_file" ]; then
            (umask 077 && ${lib.getExe pkgs.openssl} rand -hex 32 > "$key_file")
          fi
          TOKENROUTER_SECRET_ENCRYPTION_KEY="$(cat "$key_file")"
          export TOKENROUTER_SECRET_ENCRYPTION_KEY
        fi

        export TOTP_ENCRYPTION_KEY="''${TOTP_ENCRYPTION_KEY:-$TOKENROUTER_SECRET_ENCRYPTION_KEY}"

        if [ -n "''${CREDENTIALS_DIRECTORY:-}" ] && [ -r "$CREDENTIALS_DIRECTORY/admin-password" ] && [ -z "''${ADMIN_PASSWORD:-}" ]; then
          ADMIN_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/admin-password")"
          export ADMIN_PASSWORD
        fi

        if [ -e "/var/lib/tokenrouter/.installed" ] || [ "''${SKIP_SETUP:-}" = "true" ]; then
          export CONFIG_FILE=${configFile}
        else
          export SERVER_HOST=${lib.escapeShellArg cfg.settings.server.host}
          export SERVER_PORT=${lib.escapeShellArg (toString cfg.settings.server.port)}
          export SERVER_MODE=${lib.escapeShellArg cfg.settings.server.mode}
          export DATABASE_HOST=${lib.escapeShellArg cfg.settings.database.host}
          export DATABASE_PORT=${lib.escapeShellArg (toString cfg.settings.database.port)}
          export DATABASE_USER=${lib.escapeShellArg cfg.settings.database.user}
          export DATABASE_DBNAME=${lib.escapeShellArg cfg.settings.database.dbname}
          export DATABASE_SSLMODE=${lib.escapeShellArg cfg.settings.database.sslmode}
          export REDIS_HOST=${lib.escapeShellArg cfg.settings.redis.host}
          export REDIS_PORT=${lib.escapeShellArg (toString cfg.settings.redis.port)}
          export REDIS_DB=${lib.escapeShellArg (toString cfg.settings.redis.db)}
          export REDIS_ENABLE_TLS=${lib.escapeShellArg (lib.boolToString cfg.settings.redis.enable_tls)}
          export TZ=${lib.escapeShellArg cfg.settings.timezone}
        fi

        exec ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        Type = "simple";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        LoadCredential = lib.optional (
          cfg.initialAdmin.passwordFile != null
        ) "admin-password:${cfg.initialAdmin.passwordFile}";

        DynamicUser = true;
        User = "tokenrouter";
        Group = "tokenrouter";
        SupplementaryGroups = lib.optional cfg.redis.createLocally config.services.redis.servers.tokenrouter.group;

        WorkingDirectory = "/var/lib/tokenrouter";
        Restart = "always";
        RestartSec = "5s";

        StateDirectory = "tokenrouter";
        StateDirectoryMode = "0750";
        RuntimeDirectory = lib.mkIf (!useSocket && isUnixHost) "tokenrouter";

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        UMask = "0077";
      };
    };
  };
}
