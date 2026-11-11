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

  toNpgsqlString =
    attrs:
    lib.concatStringsSep ";" (
      lib.mapAttrsToList (key: value: "${key}=${toString value}") (
        lib.filterAttrs (_n: v: v != null) attrs
      )
    );
in
{
  imports = [
    (lib.modules.mkRemovedOptionModule [
      "services"
      "gzctf"
      "serverPort"
    ] "It was never applied; set services.gzctf.settings.Kestrel.Endpoints instead.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "gzctf"
      "metricPort"
    ] "It was never applied; set services.gzctf.settings.Kestrel.Endpoints instead.")
  ];

  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options = {
    services.gzctf = {
      enable = lib.mkEnableOption "GZCTF, an open source CTF platform";

      package = lib.mkPackageOption pkgs "gzctf" { };

      database.createLocally = lib.mkEnableOption "a local PostgreSQL database for GZCTF";

      docker.createLocally = lib.mkEnableOption "a local Docker daemon as the GZCTF container provider";

      redis = {
        enable = lib.mkEnableOption "Redis cache for GZCTF";
        createLocally = lib.mkEnableOption "a local Redis instance for GZCTF";
        host = lib.mkOption {
          type = lib.types.str;
          default = "localhost";
          description = "Redis host.";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 6379;
          description = "Redis port.";
        };
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        example = {
          Kestrel.Endpoints = {
            Web.Url = "http://127.0.0.1:8080";
            Prometheus.Url = "http://127.0.0.1:3000";
          };
        };
        description = ''
          GZCTF {file}`appsettings.json`, see <https://github.com/GZTimeWalker/GZCTF>.

          Options containing secret data should be set to an attribute set
          containing the attribute `_secret` - a string pointing to a file
          containing the value the option should be set to.
        '';
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
        # Kestrel endpoints are free-form URLs, so privileged ports are always allowed.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        SystemCallArchitectures = "native";
      };
    };
  };
}
