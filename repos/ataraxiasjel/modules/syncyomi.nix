{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.syncyomi;
in
{
  options.services.syncyomi = {
    enable = mkEnableOption "Synchronize Tachiyomi across multiple devices";
    package = mkPackageOption pkgs "syncyomi" { };

    configFile = mkOption {
      type = types.str;
      description = lib.mdDoc "Path to the config file.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/syncyomi";
      description = lib.mdDoc "";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = lib.mdDoc "";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.syncyomi = {
      description = "Synchronize Tachiyomi across multiple devices";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStartPre = pkgs.writeShellScript "syncyomi-cp-config" "cp ${cfg.configFile} ${cfg.dataDir}/config.toml";
        ExecStart = "${lib.getExe cfg.package} --config ${cfg.dataDir}";
        User = cfg.user;

        ReadWritePaths = [ cfg.dataDir ];
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/syncyomi") "syncyomi";
        WorkingDirectory = cfg.dataDir;

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
        UMask = "0007";
      };
    };
  };
}
