{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.exloli-next;
in
{
  options = {
    services.exloli-next = {
      enable = lib.mkEnableOption "Exloli";

      package = lib.mkPackageOption pkgs "exloli-next" { };

      dataDir = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        default = "/var/lib/exloli-next";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.exloli-next = {
      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Type = "simple";
        Restart = "always";
        StateDirectory = "exloli-next";
        WorkingDirectory = cfg.dataDir;
        ReadWritePaths = cfg.dataDir;

        # Hardening
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        DynamicUser = true;
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        RemoveIPC = true;
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
        ProtectSystem = "full";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
