{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mcp-gateway;
  stateDir = if cfg.stateDir != null then cfg.stateDir else "/var/lib/mcp-gateway";
in
{
  imports = [ ../common/mcp-gateway.nix ];

  options.services.mcp-gateway = {
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Open `settings.server.port` in the firewall. Only meaningful when the
        gateway binds a non-loopback address.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "mcp-gateway";
      description = lib.mdDoc "User account under which mcp-gateway runs.";
    };

    group = mkOption {
      type = types.str;
      default = "mcp-gateway";
      description = lib.mdDoc "Group under which mcp-gateway runs.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ (cfg.settings.server.port or 39400) ];

    systemd.services.mcp-gateway = {
      description = "MCP Gateway";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.nodejs
        pkgs.bash
      ]
      ++ cfg.extraPackages;
      environment = {
        HOME = stateDir;
        MCP_GATEWAY_LOG_LEVEL = cfg.logLevel;
      }
      // optionalAttrs (cfg.logFormat != null) { MCP_GATEWAY_LOG_FORMAT = cfg.logFormat; }
      // cfg.extraEnvironment;
      serviceConfig = {
        Type = "simple";
        ExecStart = concatStringsSep " " (
          [
            "${getExe cfg.package}"
            "--config"
            cfg.configFile
          ]
          ++ cfg.extraArguments
        );
        Restart = "on-failure";
        RestartSec = "5s";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "mcp-gateway";
        StateDirectoryMode = "0700";
        WorkingDirectory = stateDir;
        LimitNOFILE = 65536;
        LockPersonality = true;
        MemoryMax = cfg.memoryMax;
        NoNewPrivileges = true;
        PrivateIPC = true;
        PrivateMounts = true;
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
        UMask = "0007";
      }
      // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "MCP Gateway Daemon User";
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
