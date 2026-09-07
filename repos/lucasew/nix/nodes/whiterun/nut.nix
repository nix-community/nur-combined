{ config, lib, pkgs, global, ... }:
let
  upsmonPasswordFile = "/run/nut/upsmon.password";
  notifyTypes = [
    "ONLINE"
    "ONBATT"
    "LOWBATT"
    "FSD"
    "SHUTDOWN"
    "COMMBAD"
    "COMMOK"
    "NOCOMM"
    "REPLBATT"
  ];
  # Replaces nixpkgs' default NOTIFYCMD (upssched). ASCII only: telegram-sendmail
  # rejects non-UTF-8 and this queue has already poisoned on bad bytes.
  notifySendmail = pkgs.writeShellScript "nut-notify-sendmail" ''
    set -eu
    sendmail=/run/wrappers/bin/sendmail
    [ -x "$sendmail" ] || exit 0
    type=''${NOTIFYTYPE:-unknown}
    ups=''${UPSNAME:-itaipu2}
    printf 'Subject: NUT %s %s\nFrom: nut@%s\nTo: %s\n\n%s\n' \
      "$type" "$ups" \
      ${lib.escapeShellArg config.networking.hostName} \
      ${lib.escapeShellArg global.email} \
      "''${1-}" | "$sendmail"
  '';
in
{
  power.ups = {
    enable = true;
    ups.itaipu2 = {
      driver = "sms_ser";
      port = "/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_DKCRb11CN11-if00-port0";
    };
    users.upsmon = {
      passwordFile = upsmonPasswordFile;
      upsmon = "primary";
    };
    upsmon.monitor.itaipu2 = {
      user = "upsmon";
      type = "primary";
    };
    upsmon.settings = {
      NOTIFYCMD = "${notifySendmail}";
      NOTIFYFLAG = map (t: [
        t
        "SYSLOG+EXEC"
      ]) notifyTypes;
    };
  };

  # nixpkgs starts upsd before the driver and does not restart it when
  # ups.conf changes, so it keeps the old socket path.
  systemd.services.upsdrv = {
    after = lib.mkForce [ "local-fs.target" ];
    before = [ "upsd.service" ];
  };
  systemd.services.upsd = {
    after = [
      "upsdrv.service"
      "nut-upsmon-password.service"
    ];
    requires = [ "nut-upsmon-password.service" ];
    restartTriggers = [ config.environment.etc."nut/ups.conf".source ];
  };
  systemd.services.upsmon = {
    after = [ "nut-upsmon-password.service" ];
    requires = [ "nut-upsmon-password.service" ];
  };

  systemd.services.nut-upsmon-password = {
    description = "Generate NUT upsmon protocol password";
    before = [
      "upsd.service"
      "upsmon.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "nut";
      RuntimeDirectoryPreserve = "yes";
      ExecStart = pkgs.writeShellScript "nut-upsmon-password" ''
        set -eu
        umask 077
        ${lib.getExe' pkgs.openssl "openssl"} rand -hex 16 > ${lib.escapeShellArg upsmonPasswordFile}
      '';
    };
  };
}
