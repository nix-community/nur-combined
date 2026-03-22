{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.telemt;
in
{
  options.services.telemt = {
    enable = mkEnableOption "MTProxy for Telegram on Rust + Tokio";
    package = mkPackageOption pkgs "telemt" { };

    configFile = mkOption {
      type = types.str;
      description = lib.mdDoc "Path to the config file.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/telemt";
      description = lib.mdDoc "The state directory where telemt data are stored.";
    };

    user = mkOption {
      type = types.str;
      default = "telemt";
      description = lib.mdDoc "User account under which telemt runs.";
    };

    group = mkOption {
      type = types.str;
      default = "telemt";
      description = lib.mdDoc "Group under which telemt runs.";
    };
  };

  config = mkIf cfg.enable {
    users.users.telemt = {
      isSystemUser = true;
      home = cfg.stateDir;
      group = "telemt";
    };
    users.groups.telemt = { };

    systemd.services.telemt = {
      description = "MTProxy for Telegram on Rust + Tokio";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStart = "${lib.getExe cfg.package} ${cfg.configFile}";
        User = cfg.user;
        Group = cfg.group;

        ReadOnlyPaths = [ cfg.configFile ];
        ReadWritePaths = [ cfg.stateDir ];
        StateDirectory = "telemt";
        WorkingDirectory = cfg.stateDir;

        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        LimitNOFILE = 65536;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0007";
      };
    };
  };
}
