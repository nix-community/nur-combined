{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.telemt;
  stateDir = "/var/lib/telemt";
in
{
  options.services.syncyomi = {
    enable = mkEnableOption "Synchronize Tachiyomi across multiple devices";
    package = mkPackageOption pkgs "telemt" { };

    configFile = mkOption {
      type = types.str;
      description = lib.mdDoc "Path to the config file.";
    };

    user = mkOption {
      type = types.str;
      default = "telemt";
      description = lib.mdDoc "";
    };

    group = mkOption {
      type = types.str;
      default = "telemt";
      description = lib.mdDoc "";
    };
  };

  config = mkIf cfg.enable {
    users.users.telemt = {
      isSystemUser = true;
      home = cfg.package;
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

        ReadWritePaths = [ stateDir ];
        StateDirectory = "telemt";
        WorkingDirectory = stateDir;

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
