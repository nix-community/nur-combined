{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    escapeShellArgs
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.udpxy;
in
{
  options.services.udpxy = {
    enable = mkEnableOption "";
    package = lib.mkPackageOption pkgs "udpxy" { };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.udpxy = {
      description = "udpxy Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        exec ${lib.getExe cfg.package} -T ${escapeShellArgs cfg.extraArgs}
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        # Hardening
        DynamicUser = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        UMask = "0077";
      };
    };
  };
}
