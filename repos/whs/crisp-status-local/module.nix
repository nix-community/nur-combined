{config, lib, pkgs, ...}:
let
  cfg = config.services.crisp-status-local;
  toml = pkgs.formats.toml {};
in {
  options = {
    services.crisp-status-local = {
      enable = lib.mkEnableOption (lib.mdDoc "Whether crisp-status-local is enabled");

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.callPackage ./package.nix {};
        defaultText = lib.literalExpression "pkgs.crisp-status-local";
        description = lib.mdDoc "Which crisp-status-local package to use";
      };

      token = lib.mkOption {
        type = lib.types.str;
        description = lib.mdDoc "Crisp status reporter token";
      };

      config = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = lib.mdDoc "[crisp-status-local configuration](https://github.com/crisp-im/crisp-status-local#configuration)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crisp-status-local = let
      # TODO: This leak secret to Nix cache
      configFile = toml.generate "config.cfg" (cfg.config // {
        report = {
          token = cfg.token;
        };
      });
    in {
      description = "Monitor internal hosts and report their status to Crisp Status";
      documentation = [ "https://github.com/crisp-im/crisp-status-local" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 30;
        DynamicUser = true;
        
        ExecStart = "${cfg.package}/bin/crisp-status-local -c ${configFile}";

        # Sandboxing
        ProtectProc = "invisible"; # Allow /proc but only to our process
        ProcSubset = "pid";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        DevicePolicy = "closed";
        PrivateIPC = true;
        PrivateUsers = true;
        PrivateMounts = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        SystemCallArchitectures = "native";
        ReadOnlyPaths = "/";
        SocketBindDeny = "any";
      };
    };
  };
}
