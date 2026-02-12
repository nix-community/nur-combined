{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cvm-agent;
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

      # The admin scripts use ps, grep, wc, whoami, etc.
      path = [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.procps
      ];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/var/run/stargate.tencentyun.pid";
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f /var/run/stargate.tencentyun.pid";
        ExecStart = "${cfg.package}/admin/start.sh";
        ExecStop = "${cfg.package}/admin/stop.sh";
        Restart = "always";
        RestartSec = 5;

        # Hardening
        ProtectSystem = "full";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    # The agent needs to write logs
    systemd.tmpfiles.rules = [
      "d /var/log/qcloud 0755 root root -"
    ];
  };
}
