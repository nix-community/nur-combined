{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.fake-hwclock;
  fakeHwClockBin = "${pkgs.fake-hwclock}/bin/fake-hwclock";
in
{
  options.services.fake-hwclock = {
    enable = mkEnableOption "fake hardware clock service";
  };

  config = mkIf cfg.enable {
    systemd.services.fake-hwclock = {
      description = "Restore system time on boot and save it on shutdown";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${fakeHwClockBin} load";
        ExecStop = "${fakeHwClockBin} save";
        RemainAfterExit = true;
      };
    };

    systemd.services.fake-hwclock-save = {
      description = "Periodically saves system time to file";
      after = [ "fake-hwclock.service" ];
      requires = [ "fake-hwclock.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${fakeHwClockBin} save";
        StandardOutput = "null";
      };
    };

    systemd.timers.fake-hwclock-save = {
      description = "Periodically saves system time to file";
      after = [ "fake-hwclock.service" ];
      wantedBy = [ "fake-hwclock.service" ];
      timerConfig = {
        OnActiveSec = "15min";
        OnUnitActiveSec = "15min";
      };
    };

    system.activationScripts.fake-hwclock-save.text = ''
      echo "[fake-hwclock] synchronizing fake hardware clock"
      ${fakeHwClockBin} save >/dev/null
      ${fakeHwClockBin} load >/dev/null
    '';
  };
}
