{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bark-server;

  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;

  # Files that may be readable by root only are passed via LoadCredential.
  credentialSettings = lib.filterAttrs (_: v: v != null) {
    BARK_SERVER_CERT = cfg.settings.BARK_SERVER_CERT;
    BARK_SERVER_KEY = cfg.settings.BARK_SERVER_KEY;
  };
in
{
  imports = [
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "unixSocket" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_UNIX_SOCKET" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "urlPrefix" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_URL_PREFIX" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "serverlessMode" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_SERVERLESS" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "caseSensitive" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_CASE_SENSITIVE" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "strictRouting" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_STRICT_ROUTING" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "reduceMemoryUsage" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_REDUCE_MEMORY_USAGE" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "proxyHeader" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_PROXY_HEADER" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "auth" "user" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_BASIC_AUTH_USER" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "TLS" "certFile" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_CERT" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "bark-server" "TLS" "keyFile" ]
      [ "services" "bark-server" "settings" "BARK_SERVER_KEY" ]
    )
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "host"
    ] "Set services.bark-server.settings.BARK_SERVER_ADDRESS instead.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "port"
    ] "Set services.bark-server.settings.BARK_SERVER_ADDRESS instead.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "dataDir"
    ] "The data directory is always /var/lib/bark-server.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "auth"
      "passwordFile"
    ] "Set BARK_SERVER_BASIC_AUTH_PASSWORD in services.bark-server.environmentFile instead.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "database"
      "type"
    ] "bark-server uses MySQL when BARK_SERVER_DSN is set.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "database"
      "mysqlDsn"
    ] "Set BARK_SERVER_DSN in services.bark-server.environmentFile instead.")
    (lib.modules.mkRemovedOptionModule [
      "services"
      "bark-server"
      "extraFlags"
    ] "Use services.bark-server.settings instead.")
  ];

  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options = {
    services.bark-server = {
      enable = lib.mkEnableOption "Backend of Bark";

      package = lib.mkPackageOption pkgs "bark-server" { };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/run/secrets/bark-server.env";
        description = ''
          Environment file containing secrets such as
          `BARK_SERVER_BASIC_AUTH_PASSWORD` or `BARK_SERVER_DSN`.
          Values in it override {option}`services.bark-server.settings`.
        '';
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType =
            with lib.types;
            attrsOf (
              nullOr (oneOf [
                bool
                int
                str
              ])
            );

          options = {
            BARK_SERVER_ADDRESS = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1:8080";
              description = "Address bark-server listens on.";
            };

            BARK_SERVER_UNIX_SOCKET = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              example = "/run/bark-server/bark.sock";
              description = "Unix socket bark-server listens on, instead of `BARK_SERVER_ADDRESS`.";
            };

            BARK_SERVER_CERT = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                TLS certificate file. It is passed with systemd `LoadCredential`,
                so it may be readable by root only.
              '';
            };

            BARK_SERVER_KEY = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                TLS certificate key file. It is passed with systemd `LoadCredential`,
                so it may be readable by root only.
              '';
            };
          };
        };
        default = { };
        example = {
          BARK_SERVER_BASIC_AUTH_USER = "bark";
          BARK_SERVER_PROXY_HEADER = "X-Forwarded-For";
          BARK_SERVER_REDUCE_MEMORY_USAGE = true;
        };
        description = ''
          Environment variables passed to bark-server. `null` values are omitted.

          See `bark-server --help` for available settings.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.bark-server.settings.BARK_SERVER_DATA_DIR = "/var/lib/bark-server";

    systemd.services.bark-server = {
      description = "Bark push server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = lib.mapAttrs (_: toEnvValue) (
        lib.filterAttrs (_: v: v != null) cfg.settings
        // lib.mapAttrs (name: _: "%d/${name}") credentialSettings
      );

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Type = "simple";
        Restart = "on-failure";
        StateDirectory = "bark-server";
        RuntimeDirectory = "bark-server";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        LoadCredential = lib.mapAttrsToList (name: file: "${name}:${file}") credentialSettings;

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
    };
  };
}
