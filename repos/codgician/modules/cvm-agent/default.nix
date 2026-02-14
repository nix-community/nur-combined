{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cvm-agent;

  # The agent reads /proc/self/exe to locate itself, then accesses ../logs, ../modules,
  # ../etc relative to the binary. We bind-mount the Nix store binary into an FHS path
  # so these relative paths resolve to writable state directories.
  stateDir = "/var/lib/qcloud/stargate";
in
{
  options.services.cvm-agent = {
    enable = lib.mkEnableOption "Tencent Cloud CVM guest agent (Stargate)";

    package = lib.mkPackageOption pkgs "cvm-agent" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cvm-agent = {
      description = "Tencent Cloud CVM Guest Agent (Stargate)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/stargate.tencentyun.pid";
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f /run/stargate.tencentyun.pid";
        ExecStart = "${stateDir}/bin/sgagent -d";
        Restart = "always";
        RestartSec = 5;

        # Bind-mount binary and config into the FHS state directory.
        # This makes /proc/self/exe report the FHS path so the binary's
        # relative path lookups (../logs, ../modules, ../etc) resolve correctly.
        BindReadOnlyPaths = [
          "${cfg.package}/bin/sgagent:${stateDir}/bin/sgagent"
          "${cfg.package}/etc/base.conf:${stateDir}/etc/base.conf"
        ];

        ReadWritePaths = [
          stateDir
          "/var/log/qcloud"
          "/run"
        ];

        # Hardening
        ProtectSystem = "strict";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/log/qcloud 0755 root root -"
      "d ${stateDir} 0755 root root -"
      "d ${stateDir}/logs 0755 root root -"
      "d ${stateDir}/modules 0755 root root -"
    ];
  };
}
