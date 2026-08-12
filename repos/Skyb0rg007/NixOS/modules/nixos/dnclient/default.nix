{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dnclient;
in
{
  options.services.dnclient = {
    enable = lib.mkEnableOption "Defined Networking Client";
    package = lib.mkPackageOption pkgs "dnclient";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.dnclient = {
      description = "Defined Networking Client";
      documentation = "https://docs.defined.net";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      before = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "main";
        ExecStart = "${lib.getExe cfg.package} run";
        Restart = "always";
        RestartSec = 2;
        TimeoutStartSec = 5;
        RuntimeDirectory = "defined";
        StateDirectory = "defined";

        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateIPC = true;
        PrivatePIDs = true;
        # PrivateUsers = false; # Not sure why this breaks things
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        SystemCallFilter = "@system-service";
        SystemCallArchitectures = "native";
        DeviceAllow = "/dev/net/tun";
      };
    };
  };
}
