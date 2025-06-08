{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.rqbit;
in
{
  options.services.rqbit = {
    enable = mkEnableOption "rqbit service";
    package = mkPackageOption pkgs "rqbit" { };
    location = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    users = {
      users.rqbit = {
        group = "rqbit";
        uid = config.ids.uids.rqbit;
        isSystemUser = true;
      };

      groups = {
        rqbit = {
          gid = config.ids.gids.rqbit;
        };
      };
    };

    systemd.services.rqbit = {
      wantedBy = [ "multi-user.target" ];
      description = "download daemon";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${lib.getExe' cfg.package} start ${cfg.location}";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        # ProtectHome=true would not allow BindPaths= to work across /home,
        # and ProtectHome=tmpfs would break statfs(),
        # preventing transmission-daemon to report the available free space.
        # However, RootDirectory= is used, so this is not a security concern
        # since there would be nothing in /home but any BindPaths= wanted by the user.
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        # AF_UNIX may become usable one day:
        # https://github.com/transmission/transmission/issues/441
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = [
          "@system-service"
          # Groups in @system-service which do not contain a syscall
          # listed by perf stat -e 'syscalls:sys_enter_*' transmission-daemon -f
          # in tests, and seem likely not necessary for transmission-daemon.
          "~@aio"
          "~@chown"
          "~@keyring"
          "~@memlock"
          "~@resources"
          "~@setuid"
          "~@timer"
          # In the @privileged group, but reached when querying infos through RPC (eg. with stig).
          "quotactl"
        ];
        SystemCallArchitectures = "native";

        Restart = "on-failure";
      };
    };
  };
}
