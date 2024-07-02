{ config, lib, pkgs, ... }:
let
  cfg = config.services.rinetd;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mdDoc
    mkIf
    getExe;

  cfg-file = pkgs.writeText "rinetd.conf" cfg.settings;
in
{
  options = {
    services.rinetd = {
      enable = mkEnableOption "rinetd";
      package = mkPackageOption pkgs "rinetd" { };
      settings = mkOption {
        type = types.str;
        description = mdDoc ''
          Configuration for rinetd. See example in [rinetd.conf](https://github.com/samhocevar/rinetd/blob/main/rinetd.conf)
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rinetd = {
      description = "rinetd, the internet redirection server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} -f -c ${cfg-file}";
        Type = "simple";
        Restart = "on-failure";
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateIPC = true;
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
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        SystemCallErrorNumber = "EPERM";
        UMask = "0002";
      };
    };
  };
}
