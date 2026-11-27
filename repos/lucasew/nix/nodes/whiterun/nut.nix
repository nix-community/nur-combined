{ config, lib, pkgs, global, ... }:
let
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
  # The UPS cable moved to riverwood; this host only monitors it over the
  # network and still shuts itself down when the battery goes critical.
  sops.secrets.nut-whiterun-password = {
    sopsFile = ../../../secrets/nut.yaml;
    key = "whiterun_secondary_password";
  };

  power.ups = {
    enable = true;
    mode = "netclient";

    upsmon.monitor.itaipu2 = {
      system = "itaipu2@riverwood";
      user = "whiterun";
      passwordFile = config.sops.secrets.nut-whiterun-password.path;
      type = "secondary";
    };

    upsmon.settings = {
      NOTIFYCMD = "${notifySendmail}";
      NOTIFYFLAG = map (t: [
        t
        "SYSLOG+EXEC"
      ]) notifyTypes;
    };
  };
}
