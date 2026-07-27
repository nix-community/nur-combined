{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [ "d /var/lib/backup 0700 casper users -" ];

  systemd.timers.backup-sync = {
    description = "Timer to periodically run the backup-sync script";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "17:00";
  };

  systemd.services.backup-sync = {
    description = "Create, encrypt and send a backup";
    path = with pkgs; [ rsync hostname gnutar lz4 ccrypt openssh ];

    serviceConfig = {
      Type = "simple";
      User = "casper";
      ExecStart = "${pkgs.dotfiles-bin}/bin/backup-sync";
    };
  };
}
