{ config, lib, pkgs, ... }:

{
  systemd.timers.cloud-sync = {
    description = "Timer to periodically sync up with a directory in the cloud";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*-*-* *:*:00";
  };

  systemd.services.cloud-sync = {
    description = "Sync with cloud directory";

    serviceConfig = {
      Type = "oneshot";
      User = "casper";
      WorkingDirectory = "/home/casper/Cloud";
      ExecStart = "${pkgs.bitpocket}/bin/bitpocket sync --force";
      # Send notification in case sync fails.
      ExecStopPost = "${pkgs.bash}/bin/sh -c '[ \"$EXIT_STATUS\" = 0 ] || ${pkgs.libnotify}/bin/notify-send \"Failed to sync cloud directory. Check the cloud-sync.service logs for more info.\"'";
      # Wait for the process to exit instead of sending a SIGTERM signal
      # on systemctl stop (the default). SIGCHLD is ignored by default.
      KillSignal = "SIGCHLD";
    };
    # Required for notify-send to work.
    environment.DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
  };
}
