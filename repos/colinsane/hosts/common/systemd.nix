{ ... }:
let
  # N.B.: systemd doesn't like to honor its timeout settings.
  # a timeout of 20s is actually closer to 70s,
  # because it allows 20s, then after the 20s passes decides to allow 40s, then 60s,
  # finally it peacefully kills stuff, and then 10s later actually kills shit.
  haltTimeout = 10;
in
{
  sane.persist.sys.byStore.ephemeral = [
    "/var/lib/systemd/coredump"
  ];

  security.polkit.extraConfig = ''
    /* allow ordinary users to:
     * - reboot
     * - shutdown
     * source: <https://nixos.wiki/wiki/Polkit>
     */
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })

    /* allow members of wheel to:
     * - systemctl daemon-reload
     * - systemctl stop|start|restart SERVICE
     */
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel") && (
        action.id == "org.freedesktop.systemd1.reload-daemon" ||
        action.id == "org.freedesktop.systemd1.manage-units"
      )) {
        return polkit.Result.YES;
      }
    })
  '';

  # hard to wrangle systemd early-logging and my persistence.
  # instead, don't have systemd-journald try to persist its logs at all --
  # use a separate program like rsyslogd (configured elsewhere) to ingest the journal into persistent storage
  services.journald.storage = "volatile";
  # services.journald.extraConfig = ''
  #   # docs: `man journald.conf`
  #   # merged journald config is deployed to /etc/systemd/journald.conf
  #   [Journal]
  #   # disable journal compression because the underlying fs is compressed
  #   Compress=no
  # '';

  # see: `man logind.conf`
  # don’t shutdown when power button is short-pressed (commonly done an accident, or by cats).
  #   but do on long-press: useful to gracefully power-off server.
  services.logind.powerKey = "lock";
  services.logind.powerKeyLongPress = "poweroff";
  services.logind.lidSwitch = "lock";
  # under logind, 'uaccess' tag would grant the logged in user access to a device.
  # outside logind, map uaccess tag -> plugdev group to grant that access.
  services.udev.extraRules = ''
    TAG=="uaccess" GROUP="plugdev"
  '';

  systemd.extraConfig = ''
    # DefaultTimeoutStopSec defaults to 90s, and frequently blocks overall system shutdown.
    DefaultTimeoutStopSec=${builtins.toString haltTimeout}
  '';
}
