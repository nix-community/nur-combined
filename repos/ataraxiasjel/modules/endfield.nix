{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.endfield-daily;
in
{
  options.services.endfield-daily = {
    enable = mkEnableOption "Arknights Endfield Daily Claim Bot";
    package = mkPackageOption pkgs "endfield-daily" { };

    configFile = mkOption {
      type = types.str;
      description = lib.mdDoc "Path to the config file.";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = lib.mdDoc "";
    };

    startAt = mkOption {
      type = types.str;
      default = "*-*-* 10:00:00";
      description = lib.mdDoc ''
        The schedule on which to run the `endfield-daily` service.
        Format specified by `systemd.time 7`.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.endfield-daily = {
      description = "Arknights Endfield Daily Claim Bot";
      environment = {
        CONFIG_PATH = cfg.configFile;
      };
      startAt = cfg.startAt;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe cfg.package;
        User = cfg.user;
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
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindDeny = "any";
        SystemCallFilter = "~@privileged";
        UMask = "0007";
      };
    };
  };
}
