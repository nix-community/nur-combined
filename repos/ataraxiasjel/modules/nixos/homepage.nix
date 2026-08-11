{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  cfg = config.services.homepage-dashboard;
in
{
  disabledModules = [ "${modulesPath}/services/misc/homepage-dashboard.nix" ];
  options = {
    services.homepage-dashboard = {
      enable = lib.mkEnableOption (lib.mdDoc "Homepage Dashboard");

      package = lib.mkPackageOption pkgs "homepage-dashboard" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for Homepage.";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 8082;
        description = lib.mdDoc "Port for Homepage to bind to.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/homepage-dashboard";
        description = "The directory in which homepage-dashboard will keep its config files.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "homepage";
        description = lib.mdDoc "User account under which homepage-dashboard runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "homepage";
        description = lib.mdDoc "Group account under which homepage-dashboard runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == "homepage") {
      homepage = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == "homepage") { homepage = { }; };

    systemd.services.homepage-dashboard = {
      description = "Homepage Dashboard";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOMEPAGE_CONFIG_DIR = cfg.dataDir;
        PORT = "${toString cfg.listenPort}";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
        # Hardening
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/homepage-dashboard") "homepage-dashboard";
        ReadWritePaths = lib.optionals (cfg.dataDir != "/var/lib/homepage-dashboard") [ cfg.dataDir ];
        AmbientCapabilities = lib.optionals (cfg.listenPort < 1024) [ "CAP_NET_BIND_SERVICE" ];

        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateIPC = true;
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
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindAllow = "tcp:${toString cfg.listenPort}";
        SocketBindDeny = "any";
        SystemCallFilter = "~@privileged";
        UMask = "0077";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.listenPort ]; };
  };
}
