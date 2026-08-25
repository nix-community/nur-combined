{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.rustic-exporter;
in
{

  options = {
    services.rustic-exporter = {
      enable = lib.mkEnableOption "rustic-exporter";

      package = lib.mkPackageOption pkgs "rustic-exporter" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for rustic-exporter.";
      };

      configFile = lib.mkOption {
        type = lib.types.path;
        example = "/run/secrets/rustic-exporter.toml";
        description = ''
          Path to a TOML config file.
          See <https://github.com/timtorChen/rustic-exporter#configuration-file> for more information.

          ::: {.note}
          Config file is loaded using systemd's `LoadCredential` method.
          Don't set the `config` option in {option}`arguments`.
          :::
        '';
      };

      arguments = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf lib.types.anything;

          options = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              example = "0.0.0.0";
              description = "Address on which rustic-exporter listens.";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              example = 9000;
              description = "Port on which rustic-exporter listens.";
            };

            interval = lib.mkOption {
              type = lib.types.ints.positive;
              default = 300;
              example = 1500;
              description = "Metrics collection frequency in seconds.";
            };
          };
        };

        default = { };

        description = ''
          Command line arguments to pass to rustic-exporter.
          See <https://github.com/timtorChen/rustic-exporter#command-line> for more information.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rustic-exporter = {
      description = "Rustic/restic metrics exporter for Prometheus";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart =
          let
            args = lib.cli.toCommandLineGNU { } (cfg.arguments // { config = "%d/config.toml"; });
          in
          "${lib.getExe cfg.package} ${lib.concatStringsSep " " args}";
        LoadCredential = [
          "config.toml:${cfg.configFile}"
        ];
        Restart = "on-failure";
        RestartSec = 5;

        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        RemoveIPC = true;
        RestrictAddressFamilies = [
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
        UMask = "0077"; # 600 for files, 700 for dirs
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.arguments.port ];
    };
  };
}
