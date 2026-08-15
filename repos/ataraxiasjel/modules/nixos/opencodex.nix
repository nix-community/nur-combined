{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.opencodex;
  stateDir = if cfg.stateDir != null then cfg.stateDir else "/var/lib/opencodex";
in
{
  imports = [ ../common/opencodex.nix ];

  options.services.opencodex = {
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Open `port` in the firewall. Only meaningful when the service binds a
        non-loopback `hostname` (set from the opencodex dashboard).
      '';
    };

    user = mkOption {
      type = types.str;
      default = "opencodex";
      description = lib.mdDoc "User account under which opencodex runs.";
    };

    group = mkOption {
      type = types.str;
      default = "opencodex";
      description = lib.mdDoc "Group under which opencodex runs.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.opencodex = {
      description = "OpenCodex Proxy Server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        HOME = stateDir;
        OPENCODEX_HOME = stateDir;
      }
      // cfg.extraEnvironment;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe cfg.package} start --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "opencodex";
        StateDirectoryMode = "0700";
        WorkingDirectory = stateDir;
        LimitNOFILE = 65536;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateIPC = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
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
        ProtectSystem = "strict";
        ReadWritePaths = [ "/tmp" ];
        UMask = "0007";
      }
      // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "OpenCodex Daemon User";
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
