{ config, lib, ... }:

let
  cfg = config.services.metapi;
  dataDirName = builtins.baseNameOf cfg.dataDir;
in
{
  options.services.metapi = {
    enable = lib.mkEnableOption "metapi — AI API gateway meta-aggregation layer";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The metapi package to use.";
      example = lib.literalExpression "inputs.nur.repos.mcseekeri.metapi";
    };

    environmentFile = lib.mkOption {
      type = lib.types.externalPath;
      example = "/run/secrets/metapi-env";
      description = ''
        Path to a systemd EnvironmentFile loaded at runtime.

        https://metapi.cita777.me/configuration
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4000;
      description = "HTTP server listen port.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the HTTP port in the firewall.";
    };

    dataDir = lib.mkOption {
      type = lib.types.externalPath;
      default = "/var/lib/metapi";
      description = ''
        Persistent data directory for the SQLite database and runtime state.
        This must be a direct child of `/var/lib` so systemd `StateDirectory`
        can manage ownership for the dynamic service user.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/var/lib/" cfg.dataDir && builtins.dirOf cfg.dataDir == "/var/lib";
        message = "services.metapi.dataDir must be a direct child of /var/lib when DynamicUser is enabled.";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.metapi = {
      description = "Metapi — AI API Aggregation Gateway";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PORT = toString cfg.port;
        DATA_DIR = cfg.dataDir;
        NODE_ENV = "production";
      };

      preStart = ''
        ${cfg.package}/bin/metapi-migrate
      '';

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = cfg.environmentFile;
        StateDirectory = dataDirName;
        StateDirectoryMode = "0750";
        Restart = "always";
        RestartSec = "5";

        CapabilityBoundingSet = [ "" ];
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        UMask = "0077";

        PrivateUsers = true;

        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        LockPersonality = true;

        SystemCallArchitectures = "native";
        RestrictRealtime = true;
        RestrictNamespaces = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
    };
  };
}
