{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.gzctf;
  settingsFormat = pkgs.formats.json { };

  bindPrivileged = cfg.serverPort < 1024 || cfg.metricPort < 1024;

  toNpgsqlString =
    attrs:
    lib.concatStringsSep ";" (
      lib.mapAttrsToList (key: value: "${key}=${toString value}") (
        lib.filterAttrs (_n: v: v != null) attrs
      )
    );
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options = {
    services.gzctf = {
      enable = lib.mkEnableOption "";

      package = lib.mkPackageOption pkgs "gzctf" { };

      database = {
        createLocally = lib.mkEnableOption "";
      };
      docker = {
        createLocally = lib.mkEnableOption "";
      };
      redis = {
        enable = lib.mkEnableOption "";
        createLocally = lib.mkEnableOption "";
        host = lib.mkOption {
          type = lib.types.str;
          default = "localhost";
          description = "";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 6379;
          description = "";
        };
      };

      serverPort = lib.mkOption {
        type = lib.types.port;
        default = 28080;
        description = "";
      };

      metricPort = lib.mkOption {
        type = lib.types.port;
        default = 23000;
        description = "";
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        description = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    services.gzctf = {
      settings = {
        ConnectionStrings = {
          Database = lib.mkIf cfg.database.createLocally (toNpgsqlString {
            Host = "/run/postgresql";
            Port = 5432;
            Database = "gzctf";
            Username = "gzctf";
          });
          RedisCache = lib.mkIf cfg.redis.enable "${cfg.redis.host}:${toString cfg.redis.port}";
        };
        ContainerProvider = lib.mkIf cfg.docker.createLocally {
          Type = "Docker";
          DockerConfig.Uri = "unix:///run/docker.sock";
        };
      };
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "gzctf" ];
      ensureUsers = [
        {
          name = "gzctf";
          ensureDBOwnership = true;
        }
      ];
    };

    virtualisation.docker.enable = cfg.docker.createLocally;

    services.redis.servers = lib.mkIf (cfg.redis.createLocally && cfg.redis.enable) {
      gzctf = {
        enable = true;
        port = cfg.redis.port;
      };
    };

    systemd.services.gzctf = {
      description = "Open source CTF platform.";
      after = [
        "network.target"
      ]
      ++ lib.optional cfg.database.createLocally "postgresql.target"
      ++ lib.optional cfg.docker.createLocally "docker.service"
      ++ lib.optional cfg.redis.createLocally "redis-gzctf.service";
      wantedBy = [ "multi-user.target" ];
      requires =
        lib.optional cfg.database.createLocally "postgresql.target"
        ++ lib.optional cfg.docker.createLocally "docker.service"
        ++ lib.optional cfg.redis.createLocally "redis-gzctf.service";
      serviceConfig = {
        ExecStartPre =
          let
            script = pkgs.writeShellScript "gzctf-pre-start" ''
              mkdir -p /var/lib/gzctf/files
              ${utils.genJqSecretsReplacementSnippet cfg.settings "/var/lib/gzctf/appsettings.json"}
              chown -R --reference=/run/gzctf /var/lib/private/gzctf
            '';
          in
          "+${script}";
        ExecStart = lib.getExe cfg.package;
        Type = "simple";
        Restart = "on-failure";
        StateDirectory = "gzctf";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "gzctf";
        RuntimeDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/gzctf";

        User = "gzctf";
        Group = "gzctf";
        DynamicUser = true;
        SupplementaryGroups = lib.optional cfg.docker.createLocally "docker";

        # Hardening
        ReadWritePaths = [
          "/var/lib/gzctf"
        ]
        ++ lib.optional cfg.docker.createLocally "/run/docker.sock"
        ++ lib.optional cfg.database.createLocally "/run/postgresql";
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        # ProcSubset = "pid";
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
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        PrivateUsers = false;
        AmbientCapabilities = if bindPrivileged then "CAP_NET_BIND_SERVICE" else "";
        CapabilityBoundingSet = if bindPrivileged then "CAP_NET_BIND_SERVICE" else "";
        SystemCallArchitectures = "native";
      };
    };
  };
}
