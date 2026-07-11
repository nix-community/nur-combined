{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rclamonacc;

  rclamonacc-pkg = cfg.package;

  configFile = pkgs.writeText "rclamonacc.json" (builtins.toJSON cfg.settings);
in
{
  options.services.rclamonacc = {
    enable = lib.mkEnableOption "rclamonacc real-time ClamAV scanner";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/rclamonacc {
        maintainers = (import ../lib { inherit pkgs; }).maintainers;
      };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/rclamonacc { }";
      description = "The rclamonacc package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
        options = {
          socket_path = lib.mkOption {
            type = lib.types.str;
            default = "/run/clamav/clamd.ctl";
            description = "Path to the ClamAV daemon socket.";
          };
          pid_path = lib.mkOption {
            type = lib.types.str;
            default = "/run/clamav/clamd.pid";
            description = "Path to the ClamAV daemon PID file.";
          };
          max_connection = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 20;
            description = "Maximum number of connections to the ClamAV daemon.";
          };
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "List of directories to monitor in real-time.";
          };
          deny_on_error = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to deny file access when scanning fails or errors.";
          };
          pids = lib.mkOption {
            type = lib.types.listOf lib.types.ints.unsigned;
            default = [ ];
            description = "List of PIDs to exclude from scanning.";
          };
        };
      };
      default = { };
      description = "Settings for rclamonacc.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.clamav.daemon.enable;
        message = "rclamonacc requires services.clamav.daemon.enable to be enabled.";
      }
    ];

    systemd.services.rclamonacc = {
      description = "rclamonacc real-time ClamAV scanner";
      wantedBy = [ "multi-user.target" ];
      after = [ "clamav-daemon.service" ];
      requires = [ "clamav-daemon.service" ];
      serviceConfig = {
        ExecStart = "${rclamonacc-pkg}/bin/rclamonacc ${configFile}";
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";

        # Run as root but restrict capabilities to only what is needed for fanotify and file reading
        CapabilityBoundingSet = [
          "CAP_SYS_ADMIN"
          "CAP_DAC_OVERRIDE"
          "CAP_DAC_READ_SEARCH"
        ];
        NoNewPrivileges = true;

        # Sandboxing / Security hardening
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
