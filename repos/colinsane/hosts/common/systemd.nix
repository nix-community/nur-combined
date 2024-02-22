{ pkgs, ... }:
{
  systemd.extraConfig = ''
    # DefaultTimeoutStopSec defaults to 90s, and frequently blocks overall system shutdown.
    DefaultTimeoutStopSec=20
  '';

  systemd.user.extraConfig = ''
    # DefaultTimeoutStopSec defaults to 90s, and frequently blocks overall system shutdown.
    DefaultTimeoutStopSec=20
  '';

  services.journald.extraConfig = ''
    # docs: `man journald.conf`
    # merged journald config is deployed to /etc/systemd/journald.conf
    [Journal]
    # disable journal compression because the underlying fs is compressed
    Compress=no
  '';

  # decreasing the timeout for the manager itself ("Stop job is running for User Manager for UID 1000").
  # TimeoutStopSec gets stripped from .override file for `user@`, so can't do it that way:
  #   systemd.services."user@".serviceConfig.TimeoutStopSec = "20s";
  # adding just TimeoutStopSec to `user@1000` causes it to lose all the other fields, including `ExecStart`:
  #   systemd.services."user@1000".serviceConfig.TimeoutStopSec = "20s";
  # so, just recreate the whole damn service as it appears with `systemd cat 'user@1000'`
  # and modify the parts i care about.
  systemd.services."user@1000" = {
    description = "User Manager for UID %i";
    documentation = [ "man:user@service(5)" ];
    after = [
      "user-runtime-dir@%i.service"
      "dbus.service"
      "systemd-oomd.service"
    ];
    requires = [ "user-runtime-dir@%i.service" ];
    unitConfig.ignoreOnIsolate = true;

    serviceConfig = {
      User = "%i";
      PAMName = "systemd-user";
      Type = "notify-reload";
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd --user";
      Slice = "user-%i.slice";
      KillMode = "mixed";
      Delegate = [ "pids" "memory" "cpu" ];
      DelegateSubgroup = "init.scope";
      TasksMax = "infinity";
      TimeoutStopSec = "20s";  #< default: 120s
      KeyringMode = "inherit";
      OOMScoreAdjust = 100;
      MemoryPressureWatch = "skip";
    };
  };

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
