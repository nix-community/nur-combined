{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.clash-nyanpasu;
in
{
  options.programs.clash-nyanpasu = {
    enable = lib.mkEnableOption "Clash Nyanpasu";
    package = lib.mkPackageOption pkgs "clash-nyanpasu" { };
    tunMode = lib.mkEnableOption "Setcap for TUN Mode. DNS settings won't work on this way";
    autoStart = lib.mkEnableOption "Clash Nyanpasu auto launch";
    serviceMode = {
      enable = lib.mkEnableOption "Nyanpasu privileged service";

      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "alice" ];
        description = ''
          Local desktop users allowed to access the Nyanpasu unix socket.
          They will be added to the nyanpasu group.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        example = "/home/alice/.local/share/clash-nyanpasu";
        description = "Nyanpasu data directory passed to --nyanpasu-data-dir.";
      };

      configDir = lib.mkOption {
        type = lib.types.str;
        example = "/home/alice/.config/clash-nyanpasu";
        description = "Nyanpasu config directory passed to --nyanpasu-config-dir.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ]
    ++ lib.optional cfg.autoStart (
      pkgs.makeAutostartItem {
        name = "Clash Nyanpasu";
        package = cfg.package;
      }
    );

    security.wrappers."Clash Nyanpasu" = lib.mkIf cfg.tunMode {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service,cap_net_raw,cap_net_admin=+ep";
      source = lib.getExe cfg.package;
    };

    users.groups.nyanpasu.members = lib.mkIf cfg.serviceMode.enable cfg.serviceMode.users;
    systemd.services.elaina-nyanpasu-service = lib.mkIf cfg.serviceMode.enable {
      description = "Nyanpasu privileged service";
      wantedBy = lib.optional cfg.autoStart "multi-user.target";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        RUST_LOG = "info";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe' cfg.package "nyanpasu-service")
          "server"
          "--nyanpasu-data-dir"
          cfg.serviceMode.dataDir
          "--nyanpasu-config-dir"
          cfg.serviceMode.configDir
          "--nyanpasu-app-dir"
          "${cfg.package}/bin"
          "--service"
        ];
        WorkingDirectory = "/var/lib/nyanpasu-service";
        Restart = "on-failure";
        RestartSec = "3s";
        UMask = "0022";

        ReadWritePaths = [
          "/run" # /run/nyanpasu_ipc.sock
          cfg.serviceMode.dataDir
          cfg.serviceMode.configDir
        ];

        DeviceAllow = [ "/dev/net/tun rw" ];

        ProtectSystem = "strict";
        NoNewPrivileges = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        SystemCallArchitectures = "native";
        PrivateTmp = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RuntimeDirectory = "nyanpasu-service";
        ConfigurationDirectory = "nyanpasu-service";
        StateDirectory = "nyanpasu-service";
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = [
          "~user"
          "~cgroup"
          "~mnt"
          "~uts"
        ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_PACKET"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_DAC_OVERRIDE"
          "CAP_CHOWN"
          "CAP_FOWNER"
          "CAP_NET_BIND_SERVICE"
          "CAP_KILL"
        ];
        SystemCallFilter = [
          "~@aio"
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@module"
          "~@obsolete"
          "~@pkey"
          "~@raw-io"
          "~@reboot"
          "~@swap"
          "~@timer"
        ];
        SystemCallErrorNumber = "EPERM";
      };
    };
  };
}
