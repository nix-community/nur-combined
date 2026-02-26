{
  lib,
  config,
  self,
  system,
  ...
}:
let
  cfg = config.vintagestory;
in
{
  options.vintagestory = {
    enable = lib.mkEnableOption "Vintage Story dedicated server";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${system}.VintagestoryServer;
      description = "The Vintage Story server package to use.";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/vintagestory";
      description = "Directory to store Vintage Story server data (worlds, configs, mods).";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the default Vintage Story server port (42420) in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.vintagestory = {
      description = "Vintage Story server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "vintagestory";
    };
    users.groups.vintagestory = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 vintagestory vintagestory -"
    ];

    systemd.services.vintagestory = {
      description = "Vintage Story Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/VintagestoryServer --dataPath ${cfg.dataDir}";
        Restart = "always";
        RestartSec = "10s";
        User = "vintagestory";
        Group = "vintagestory";
        WorkingDirectory = cfg.dataDir;

        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.dataDir ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 42420 ];
      allowedUDPPorts = [ 42420 ];
    };
  };
}
