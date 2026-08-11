{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.hoyolab-claim-bot;
in
{
  options.services.hoyolab-claim-bot = {
    enable = mkEnableOption "Hoyolab Daily Claim Bot";
    package = mkPackageOption pkgs "hoyolab-claim-bot" { };

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
      default = "*-*-* 20:00:00";
      description = lib.mdDoc ''
        The schedule on which to run the `hoyolab-claim-bot` service.
        Format specified by `systemd.time 7`.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hoyolab-claim-bot = {
      description = "Hoyolab Daily Claim Bot.";
      startAt = cfg.startAt;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/hoyolab-claim-bot ${cfg.configFile}";
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
