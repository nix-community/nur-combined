{ config, lib, ... }:
{
  power.ups = {
    enable = true;
    upsmon.enable = false;
    ups.ups = {
      driver = "sms_ser";
      port = "/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_DKCRb11CN11-if00-port0";
    };
  };

  # nixpkgs starts upsd before the driver and does not restart it when
  # ups.conf changes, so it keeps the old socket path.
  systemd.services.upsdrv = {
    after = lib.mkForce [ "local-fs.target" ];
    before = [ "upsd.service" ];
  };
  systemd.services.upsd = {
    after = [ "upsdrv.service" ];
    restartTriggers = [ config.environment.etc."nut/ups.conf".source ];
  };

  # upsc is anonymous. A system unit already has the right to poweroff;
  # no NUT protocol user, password, or polkit rule.
  systemd.services.nut-lowbatt-poweroff = {
    description = "Power off when NUT reports low battery";
    after = [ "upsd.service" ];
    path = [
      config.power.ups.package
      config.systemd.package
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      status=$(upsc ups ups.status 2>/dev/null || true)
      case "$status" in
        *LB*|*FSD*) systemctl poweroff ;;
      esac
    '';
  };

  systemd.timers.nut-lowbatt-poweroff = {
    wantedBy = [ "timers.target" ];
    after = [ "upsd.service" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "15s";
    };
  };
}
