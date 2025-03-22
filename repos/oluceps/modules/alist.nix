{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.alist;
  inherit (lib)
    mkPackageOption
    mkIf
    mkEnableOption
    ;
in
{
  options.services.alist = {
    enable = mkEnableOption "alist";
    package = mkPackageOption pkgs "alist" { };
  };
  config = mkIf cfg.enable {
    systemd.services.alist = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "alist Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "alist";
        RuntimeDirectory = "alist";
        Environment = [ "TMP_DIR=\${RUNTIME_DIRECTORY}" ];
        ExecStart = "${lib.getExe cfg.package} server --data $\{STATE_DIRECTORY} --log-std";
        Restart = "on-failure";
        WorkingDirectory = "/var/lib/alist";
        PrivateTmp = true;
        PrivateUsers = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        MemoryDenyWriteExecute = true;
        UMask = "0077";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };
    };
  };
}
