{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bark-server;
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options = {
    services.bark-server = {
      enable = lib.mkEnableOption "Backend of Bark";

      package = lib.mkPackageOption pkgs "bark-server" { };

      host = lib.mkOption {
        type = with lib.types; nullOr str;
        default = "127.0.0.1";
      };

      port = lib.mkOption {
        type = with lib.types; nullOr port;
        default = 8080;
      };

      unixSocket = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/bark-server";
        readOnly = true;
      };

      serverlessMode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable serverless mode.
        '';
      };

      urlPrefix = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      caseSensitive = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      strictRouting = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      reduceMemoryUsage = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      proxyHeader = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      auth = {
        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            Path to the file contained the password
            Leave empty to not enable auth
          '';
        };
      };

      database = {
        type = lib.mkOption {
          type = lib.types.enum [
            "bbolt"
            "mysql"
          ];
          default = "bbolt";
          description = ''
            Use mysql as database or the embedded bbolt
          '';
        };
        # TODO: add createMysqlLocally
        mysqlDsn = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            DSN to connect to mysql database
          '';
        };
      };

      TLS = {
        certFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            Path to the file contained the TLS certificate
            Leave empty to not offer TLS
          '';
        };
        keyFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            Path to the file contained the TLS certificate key
            Leave empty to not offer TLS
          '';
        };
      };
      extraFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = '''';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.bark-server = {
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        StateDirectory = baseNameOf cfg.dataDir;
        RuntimeDirectory = "bark-server";
        LoadCredential =
          lib.optional (!isNull cfg.auth.passwordFile) "auth-password:${cfg.auth.passwordFile}"
          ++ lib.optional (!isNull cfg.database.mysqlDsn) "mysql-dsn:${cfg.database.mysqlDsn}"
          ++ lib.optional (!isNull cfg.TLS.certFile) "tls-certfile:${cfg.TLS.certFile}"
          ++ lib.optional (!isNull cfg.TLS.keyFile) "tls-keyfile:${cfg.TLS.keyFile}";

        DynamicUser = true;
        UMask = "0077";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
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
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [
          "@system-service"
          # Route-chain and OpenJ9 requires @resources calls
          "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
        ];
      };
      script = lib.concatStringsSep " " (
        [
          "exec"
          "${lib.getExe cfg.package}"
          "--data ${cfg.dataDir}"
        ]
        ++ lib.optional (cfg.unixSocket != null) "--unix-socket ${cfg.unixSocket}"
        ++ lib.optional (cfg.host != null && cfg.port != null) "--addr ${cfg.host}:${toString cfg.port}"
        ++ lib.optional cfg.serverlessMode "--serverless"
        ++ lib.optional cfg.caseSensitive "--case-sensitive"
        ++ lib.optional cfg.strictRouting "--strict-routing"
        ++ lib.optional cfg.reduceMemoryUsage "--reduce-memory-usage"
        ++ lib.optional (!isNull cfg.auth.user) "--user ${cfg.auth.user}"
        ++ lib.optional (
          !isNull cfg.auth.passwordFile
        ) "--password $(cat $CREDENTIALS_DIRECTORY/auth-password)"
        ++ lib.optional (!isNull cfg.database.mysqlDsn) "--dsn $(cat $CREDENTIALS_DIRECTORY/mysql-dsn)"
        ++ lib.optional (!isNull cfg.TLS.certFile) "--cert $CREDENTIALS_DIRECTORY/tls-certfile"
        ++ lib.optional (!isNull cfg.TLS.keyFile) "--key $CREDENTIALS_DIRECTORY/tls-keyfile"
        ++ lib.optional (!isNull cfg.proxyHeader) "--proxy-header ${cfg.proxyHeader}"
        ++ lib.optional (!isNull cfg.urlPrefix) "--url-prefix ${cfg.urlPrefix}"
        ++ cfg.extraFlags
      );
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
