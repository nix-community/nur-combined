{ config, pkgs, lib, ... }:
let
  cfg = config.services.linx-server;

  configFormat = pkgs.formats.keyValue { };
  configFile = configFormat.generate "linx-server.conf" cfg.config;
in {
  options.services.linx-server = with lib; {
    enable = mkEnableOption "linx-server";
    package = mkPackageOption pkgs "linx-server" { };

    config = mkOption {
      type = types.submodule {
        freeformType = configFormat.type;
        options = {
          bind = mkOption {
            type = types.str;
            default = "127.0.0.1:8080";
          };

          filespath = mkOption {
            type = types.path;
          };
          metapath = mkOption {
            type = types.path;
          };
          lockspath = mkOption {
            type = types.path;
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.linx-server.config = {
      filespath = "/var/lib/linx-server/files";
      metapath = "/var/lib/linx-server/meta";
      lockspath = "/var/lib/linx-server/locks";
    };

    systemd.services.linx-server = {
      description = "Self-hosted file/code/media sharing website";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/linx-server -config=${configFile}";

        DynamicUser = true;
        StateDirectory = "linx-server";

        Restart = "on-failure";
        RestartSec = "5s";
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        # A private user cannot have process capabilities on the host's user
        # namespace and thus CAP_NET_BIND_SERVICE has no effect.
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        # SystemCallFilter = [
        #   "@system-service"
        #   "~@privileged"
        #   "~@resources"
        # ];
        UMask = "0077";
      };
    };
  };
}
