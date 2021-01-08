{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.etlegacy;
  stateDir = "/var/lib/${cfg.stateDirName}";

in {
  options = {
    services.etlegacy = {
      enable = mkEnableOption "ET: legacy dedicated server";

      bind = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Bind on this network IP, it not specified will bind on all IP's.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 27960;
        description = ''
          The port to which the service should bind.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to automatically open the specified UDP port in the firewall.
        '';
      };

      configFile = mkOption {
        type = types.path;
        description = "The server's configuration file.";
      };

      stateDirName = mkOption {
        type = types.str;
        default = "etlegacy";
        description = ''
          Name of the directory under /var/lib holding the server's data.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.etlegacy;
        defaultText = "pkgs.legacy";
        description = "etlegacy package to run";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.etlegacy = {
      description = "ET: Legacy dedicated server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Restart = "always";
        KillSignal = "SIGINT";
        DynamicUser = true;
        StateDirectory = cfg.stateDirName;
        UMask = "0007";

        ExecStartPre = "+${
            pkgs.writeShellScript "etlegacy-config" ''
              mkdir -p ${stateDir}/legacy
              cp ${cfg.configFile} ${stateDir}/legacy/server.cfg
            ''
          }";

        ExecStart = toString [
          "${cfg.package}/bin/etlded"
          "+set fs_homepath ${cfg.package}/share"
          "+set fs_basepath ${stateDir}"
          "+set net_port ${toString cfg.port}"
          (optionalString (cfg.bind != null) "+set net_ip ${cfg.bind}")
          "+exec server.cfg"
        ];

        # Sandboxing
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        PrivateMounts = true;
        MemoryDenyWriteExecute = true;
        # System Call Filtering
        SystemCallArchitectures = "native";
      };
    };

    networking.firewall.allowedUDPPorts =
      if cfg.openFirewall then [ cfg.port ] else [ ];
  };

}
