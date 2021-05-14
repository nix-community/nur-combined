{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.nats;

  confFile = pkgs.writeText "nats.conf" (builtins.toJSON cfg.settings);

in {

  ### Interface

  options = {
    services.nats = {
      enable = mkEnableOption "NATS messaging system";

      package = mkOption {
        type = types.package;
        default = pkgs.nats-server;
        defaultText = "pkgs.nats-server";
        description = "The nats-server package to use";
      };

      user = mkOption {
        type = types.str;
        default = "nats";
        description = "User account under which NATS runs.";
      };

      group = mkOption {
        type = types.str;
        default = "nats";
        description = "Group under which NATS runs.";
      };

      serverName = mkOption {
        default = "nats";
        example = "n1-c3";
        type = types.str;
        description = ''
          Name of the NATS server, must be unique if clustered.
        '';
      };

      jetstream = mkOption {
        type = types.bool;
        default = false;
        description = "Enable JetStream";
      };

      host = mkOption {
        default = "127.0.0.1";
        example = "0.0.0.0";
        type = types.str;
        description = ''
          Host to listen on.
        '';
      };

      port = mkOption {
        default = 4222;
        example = 4222;
        type = types.int;
        description = ''
          Port on which to listen.
        '';
      };

      dataDir = mkOption {
        default = "/var/lib/nats";
        type = types.path;
        description = ''
          The data directory.
        '';
      };

      settings = mkOption {
        default = {};
        type = types.submodule {
          freeformType = with lib.types; attrsOf anything;
          options = { };
        };
        example = literalExample ''
          {
            jetstream = {
              max_mem = "1G";
              max_file = "10G";
            };
          };
        '';
        description = ''
          Declarative Nats configuration. See https://docs.nats.io/nats-server/configuration
        '';
      };
    };
  };

  ### Implementation

  config = mkIf cfg.enable {
    services.nats.settings = {
      server_name = mkDefault cfg.serverName;
      host = mkDefault cfg.host;
      port = mkDefault cfg.port;
        jetstream = optionalAttrs cfg.jetstream {
        store_dir = mkDefault cfg.dataDir;
      };
    };
   
    systemd.services.nats = {
      description = "NATS messaging system";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartTriggers = [ confFile ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/nats-server -c ${confFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${pkgs.coreutils}/bin/kill -SIGINT $MAINPID";
        Restart = "on-failure";

        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "nats";

        # Hardening
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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
        ProcSubset = "pid";
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.dataDir ];
        ReadOnlyPaths = [];
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        UMask = "0077";        
      };
    };

    users.users = mkIf (cfg.user == "nats") {
      nats = {
        description = "nats daemon user";
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.group == "nats") {
      nats = {};
    };
  };

}
