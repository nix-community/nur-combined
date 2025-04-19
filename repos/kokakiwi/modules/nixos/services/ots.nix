{ config, pkgs, lib, ... }:
let
  cfg = config.services.ots;

  customizeFormat = pkgs.formats.yaml { };
  customizeFile = customizeFormat.generate "customize.yml" cfg.customize;
in {
  options.services.ots = with lib; {
    enable = mkEnableOption "OTS";
    package = mkPackageOption pkgs "ots" { };

    enableRedis = mkEnableOption "Use Redis storage";

    listenAddress = mkOption {
      type = types.str;
      default = ":3000";
    };
    secretExpiryTime = mkOption {
      type = types.ints.unsigned;
      default = 604800; # 168h = 1w
    };

    customize = mkOption {
      type = types.nullOr customizeFormat.type;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ots = {
      description = "OTS";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        LISTEN = cfg.listenAddress;
        SECRET_EXPIRY = toString cfg.secretExpiryTime;
        STORAGE_TYPE = if cfg.enableRedis then "redis" else "mem";
      } // lib.optionalAttrs (cfg.customize != null) {
        CUSTOMIZE = toString customizeFile;
      } // lib.optionalAttrs cfg.enableRedis {
        REDIS_URL = "unix://${config.services.redis.servers.ots.unixSocket}";
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/ots";

        DynamicUser = true;
        SupplementaryGroups = lib.mkIf cfg.enableRedis [
          config.services.redis.servers.ots.group
        ];

        Restart = "on-failure";
        RestartSec = "5s";
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        # A private user cannot have process capabilities on the host's user
        # namespace and thus CAP_NET_BIND_SERVICE has no effect.
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
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ] ++ lib.optionals cfg.enableRedis [
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    services.redis.servers = lib.mkIf cfg.enableRedis {
      ots = {
        enable = true;
      };
    };
  };
}
