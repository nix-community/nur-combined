{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.subconverter;
in
{
  options.services.subconverter = {
    enable = lib.mkEnableOption "subconverter, Utility to convert between various subscription format.";

    package = lib.mkPackageOption pkgs [ "nur" "repos" "moraxyc" "subconverter" ] { };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Configuration file to use.";
      default = cfg.package.data.outPath;
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open ports in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (pkgs ? nur);
        message = ''
          The default package for services.subconverter comes from NUR repository.
          To use the default package, you must import NUR.
          Alternatively, you can override the package.
        '';
      }
    ];
    
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 25500 ];
      allowedUDPPorts = [ 25500 ];
    };

    systemd.services."subconverter" = {
      description = "subconverter daemon, Utility to convert between various subscription format.";
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = lib.concatStringsSep " " [
          (lib.getExe' pkgs.rsync "rsync")
          "-rlpt"
          "--ignore-existing"
          "${cfg.configFile}/"
          "$STATE_DIRECTORY"
        ];

        ExecStart = lib.getExe cfg.package;

        DynamicUser = true;
        StateDirectory = "subconverter";
        WorkingDirectory = "/var/lib/subconverter";

        # Sandboxing
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
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
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        UMask = "0077";
      };
    };
  };
}