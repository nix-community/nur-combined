{ ... }:
{
  systemd.extraConfig = ''
    # DefaultTimeoutStopSec defaults to 90s, and frequently blocks overall system shutdown.
    DefaultTimeoutStopSec=25
  '';

  systemd.user.extraConfig = ''
    # DefaultTimeoutStopSec defaults to 90s, and frequently blocks overall system shutdown.
    DefaultTimeoutStopSec=25
  '';

  services.journald.extraConfig = ''
    # docs: `man journald.conf`
    # merged journald config is deployed to /etc/systemd/journald.conf
    [Journal]
    # disable journal compression because the underlying fs is compressed
    Compress=no
  '';

  # allow ordinary users to `reboot` or `shutdown`.
  # source: <https://nixos.wiki/wiki/Polkit>
  security.polkit.extraConfig = ''
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
  '';
}
