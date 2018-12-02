{ config, pkgs, options, ... }:
{
  systemd.user.services.mbsync = {
    enable = false;
    description = "Run mbsync";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.isync}/bin/mbsync -a";
  };
  systemd.user.timers.mbsync = {
    enable = false;
    description = "run mbsync every 5 minutes";
    timerConfig = {
      OnBootSec = "10m";
      OnUnitInactiveSec = "5m";
      Unit = "mbsync.service";
    };
  };

  systemd.user.services.mu-fastmail = {
    enable = false;
    description = "Update email index for fastmail";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.mu}/bin/mu index -m /home/moredhel/mail";
  };
  systemd.user.timers.mu-fastmail = {
    enable = false;
    description = "run mu-fastmail every 5 minutes";
    timerConfig = {
      OnBootSec = "11m";
      OnUnitInactiveSec = "2m";
      Unit = "mu-fastmail.service";
    };
  };
}
