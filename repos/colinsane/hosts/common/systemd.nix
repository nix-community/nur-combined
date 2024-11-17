{ config, lib, pkgs, ... }:
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

  sane.persist.sys.byPath."/var/log/journal" = {
    # prefer to persist to private, because the journal can have sensitive info in it.
    # but plaintext also works for scenarios where the system can't be unlocked.
    store = "private";
    # store = "plaintext";
    # ordering of bind mounts is tricky for private store, so prefer symlink
    method = "symlink";
    acl.mode = "0750";
  };

  # systemd-journal-flush.service switches journald from volatile to persistent storage partway through boot
  #   ExecStart=journalctl --flush
  #   ExecStop=journalctl --smart-relinquish-var
  # - before `--flush`, data is at /run/systemd/journal
  #   flush _copies_ data from /run... to /var/log/journal
  #
  # BUT: systemd-journal-flush.service ships with `Before=systemd-tmpfiles-setup.service`, which causes a circular dependency
  # that's low-level enough to break boot (sysinit.target).
  #
  # no way to _remove_ an upstream `Before` attribute.
  # instead, neuter the service and re-implement the key bits.
  systemd.services.systemd-journal-flush.serviceConfig.ExecStart = [
    ""  #< clear original `ExecStart`
  ];

  systemd.services.systemd-journal-flush-sane = {
    description = "flush early logging data to persistent storage, but later in the boot than normal to avoid cycles";
    wantedBy = [ "systemd-journal-flush.service" ];
    serviceConfig.ExecStart = "journalctl --flush";
    # ensure /var/log/journal symlink exists before starting:
    serviceConfig.ExecStartPre = "-${lib.getExe' pkgs.systemd "systemd-tmpfiles"} --prefix=/var/log/journal --boot --create --graceful";
    unitConfig.DefaultDependencies = false;
    unitConfig.RequiresMountsFor = [
      config.sane.persist.sys.byPath."/var/log/journal".store.origin
    ];
  };

  services.journald.extraConfig = ''
    # docs: `man journald.conf`
    # merged journald config is deployed to /etc/systemd/journald.conf
    [Journal]
    # disable journal compression for better debugging (besides, my fs is already compressed)
    Compress=no
  '';

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

  # harden base systemd services
  # see: `systemd-analyze security`
  systemd.services.systemd-rfkill.serviceConfig = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    DevicePolicy = "closed";
    IPAddressDeny = "any";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateNetwork = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RemoveIPC = true;
    RestrictAddressFamilies = "AF_UNIX";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
  };
}
