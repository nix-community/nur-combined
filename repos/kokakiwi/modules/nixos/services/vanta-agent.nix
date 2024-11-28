{ config, pkgs, lib, ... }:
let
  cfg = config.services.vanta-agent;
in {
  options.services.vanta-agent = with lib; {
    enable = mkEnableOption "Vanta Agent";
    package = mkPackageOption pkgs "vanta-agent" { };
  };

  config = with lib; mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/vanta 0700 root root -"
    ];

    systemd.services.vanta-agent = {
      description = "Vanta Agent";
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        for f in ${cfg.package}/var/vanta/*; do
          cp -t /var/vanta -a "$f"
          chmod 0500 /var/vanta/$(basename "$f")
        done
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/var/vanta/metalauncher";
        Restart = "on-failure";
        StateDirectory = "vanta-agent";
        KillMode = "control-group";
        KillSignal = "SIGTERM";
        TimeoutStartSec = "0";
      };
    };
  };
}
