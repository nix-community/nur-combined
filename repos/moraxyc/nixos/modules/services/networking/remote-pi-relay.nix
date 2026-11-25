{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.remote-pi-relay;

  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;

  bindPrivileged = cfg.settings.REMOTEPI_RELAY_PORT < 1024;
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options.services.remote-pi-relay = {
    enable = lib.mkEnableOption "Remote Pi Relay, a WebSocket relay server for Remote Pi";

    package = lib.mkPackageOption pkgs "remote-pi-relay" { };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open
        {option}`services.remote-pi-relay.settings.REMOTEPI_RELAY_PORT` in the
        firewall.
      '';
    };

    configureNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to configure nginx as a reverse proxy for Remote Pi Relay.
      '';
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "relay.example.org";
      description = ''
        Domain name for the nginx virtual host.
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/remote-pi-relay.env";
      description = ''
        Environment file read by systemd. Values set here override
        {option}`services.remote-pi-relay.settings`.
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
          REMOTEPI_RELAY_PORT = lib.mkOption {
            type = lib.types.port;
            default = 3000;
            description = ''
              TCP port on which the relay serves WebSocket upgrades (`/`),
              health checks (`/health`), and mesh membership endpoints
              (`/mesh/*`).
            '';
          };

          RELAY_MAX_CT_MIB = lib.mkOption {
            type = lib.types.ints.positive;
            default = 4;
            description = ''
              Maximum outer-envelope `ct` payload size in MiB.
            '';
          };

          RUST_LOG = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = "info";
            example = "debug";
            description = ''
              Log level filter passed to `tracing-subscriber`.
            '';
          };
        };
      };
      default = { };
      example = {
        REMOTEPI_RELAY_PORT = 8080;
        RELAY_MAX_CT_MIB = 8;
        RUST_LOG = "debug";
      };
      description = ''
        Environment variables passed to `remote-pi-relay`. `null` values are
        omitted.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.remote-pi-relay.settings.REMOTEPI_MESH_DB_PATH = "/var/lib/remote-pi-relay/mesh.db";

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.settings.REMOTEPI_RELAY_PORT;

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.settings.REMOTEPI_RELAY_PORT}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    systemd.services.remote-pi-relay = {
      description = "WebSocket relay server for Remote Pi";
      documentation = [ "https://github.com/jacobaraujo7/remote_pi/tree/main/relay" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = lib.mapAttrs (_: toEnvValue) (lib.filterAttrs (_: v: v != null) cfg.settings);

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

        DynamicUser = true;
        User = "remote-pi-relay";
        Group = "remote-pi-relay";

        StateDirectory = "remote-pi-relay";
        StateDirectoryMode = "0750";
        WorkingDirectory = "/var/lib/remote-pi-relay";

        KillSignal = "SIGINT";
        Restart = "on-failure";
        RestartSec = "5s";

        # Hardening
        UMask = "0077";
        AmbientCapabilities = lib.optionalString bindPrivileged "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = lib.optionalString bindPrivileged "CAP_NET_BIND_SERVICE";
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
          "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
        ];
      };
    };
  };
}
