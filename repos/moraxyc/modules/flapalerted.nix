{
  lib,
  pkgs,
  config,
  utils,
  ...
}:

let
  cfg = config.services.flapalerted';
in
{
  options = {
    services.flapalerted' = {
      enable = lib.mkEnableOption "";

      package = lib.mkPackageOption pkgs "flapalerted" { };

      debug = lib.mkEnableOption "debug mode";

      asn = lib.mkOption {
        type = lib.types.str;
      };

      flags = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.flapalerted'.flags = [
      "-asn"
      cfg.asn
    ]
    ++ lib.optional cfg.debug "-debug";
    systemd.services.flapalerted = {
      enableStrictShellChecks = true;
      serviceConfig = {
        RuntimeDirectory = "flapalerted";
        ExecStart = "${lib.getExe cfg.package} " + lib.escapeShellArgs cfg.flags;

        # Harden
        ReadWritePaths = [ "/run/flapalerted" ];
        NoNewPrivileges = true;
        DynamicUser = true;
        RemoveIPC = true;
        PrivateMounts = true;
        RestrictSUIDSGID = true;
        ProtectHostname = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        CapabilityBoundingSet = "";
        UMask = "0177";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
