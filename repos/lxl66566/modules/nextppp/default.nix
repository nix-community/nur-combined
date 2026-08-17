{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nextppp;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/nextppp { };
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "nextppp.jsonc" cfg.settings;
in
{
  options.services.nextppp = {
    enable = lib.mkEnableOption "nextppp service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The nextppp package to use.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "server"
        "client"
      ];
      description = "Whether to run nextppp as a server or a client.";
      example = "server";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          listen = lib.mkOption {
            type = lib.types.str;
            description = "Listen address for nextppp connections.";
            example = "0.0.0.0:6666";
          };

          password = lib.mkOption {
            type = lib.types.str;
            description = "Shared tunnel password. Must be changed per deployment.";
          };
        };
      };
      description = "The nextppp configuration.";
      example = {
        listen = "0.0.0.0:6666";
        password = "CHANGE_ME";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextppp.settings =
      if cfg.mode == "server" then
        {
          listen = lib.mkDefault "0.0.0.0:6666";
          password = lib.mkDefault "CHANGE_ME";
          connect_timeout = lib.mkDefault 10;
          handshake_timeout = lib.mkDefault 15;
        }
      else
        {
          listen = lib.mkDefault "127.0.0.1:1080";
          password = lib.mkDefault "CHANGE_ME";
          server = lib.mkDefault {
            address = "your.server.example:6666";
          };
        };
    systemd.services.nextppp = {
      description = "nextppp ${cfg.mode} service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/nextppp ${cfg.mode} -c ${configFile}";

        Restart = "on-failure";
        RestartSec = 5;

        DynamicUser = true;
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
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
          "~@resources"
          "~@privileged"
        ];
        UMask = "0077";
      };
    };
  };
}
