{ config, lib, pkgs, ... }:
{
  networking.modemmanager.package = pkgs.modemmanager-split.daemon.overrideAttrs (upstream: {
    # patch to allow the dbus endpoints to be owned by networkmanager user
    postInstall = (upstream.postInstall or "") + ''
      substitute $out/share/dbus-1/system.d/org.freedesktop.ModemManager1.conf \
        $out/share/dbus-1/system.d/networkmanager-org.freedesktop.ModemManager1.conf \
        --replace-fail 'user="root"' 'group="networkmanager"'
    '';
  });

  systemd.services.ModemManager = {
    # aliases = [ "dbus-org.freedesktop.ModemManager1.service" ];
    # after = [ "polkit.service" ];
    # requires = [ "polkit.service" ];
    wantedBy = [ "network.target" ];  #< default is `multi-user.target`, somehow it doesn't auto-start with that...

    # serviceConfig.Type = "dbus";
    # serviceConfig.BusName = "org.freedesktop.ModemManager1";

    # only if started with `--debug` does mmcli let us issue AT commands like
    # `mmcli --modem any --command=<AT_CMD>`
    serviceConfig.ExecStart = [
      ""  # first blank line is to clear the upstream `ExecStart` field.
      "${lib.getExe' config.networking.modemmanager.package "ModemManager"} --debug"
    ];
    # --debug sets DEBUG level logging: so reset
    serviceConfig.ExecStartPost = "${lib.getExe config.sane.programs.mmcli.package} --set-logging=INFO";

    # v this is what upstream ships
    # serviceConfig.Restart = "on-abort";
    # serviceConfig.StandardError = "null";
    # serviceConfig.CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_NET_ADMIN";
    # serviceConfig.ProtectSystem = true;  # makes empty: /boot, /usr
    # serviceConfig.ProtectHome = true;  # makes empty: /home, /root, /run/user
    # serviceConfig.PrivateTmp = true;
    # serviceConfig.RestrictAddressFamilies = "AF_NETLINK AF_UNIX AF_QIPCRTR";
    # serviceConfig.NoNewPrivileges = true;

    serviceConfig.CapabilityBoundingSet = [
      ""  #< reset upstream capabilities
      "CAP_NET_ADMIN"
      "CAP_SYS_ADMIN"  #< TODO: remove CAP_SYS_ADMIN!
    ];
    serviceConfig.LockPersonality = true;
    # serviceConfig.PrivateUsers = true;  #< untried, not likely to work since it needs capabilities
    serviceConfig.PrivateTmp = true;
    serviceConfig.ProtectClock = true;  # syscall filter to prevent changing the RTC
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;  # makes empty: /home, /root, /run/user
    serviceConfig.ProtectHostname = true;  # prevents changing hostname
    serviceConfig.ProtectKernelLogs = true;  # disable /proc/kmsg, /dev/kmsg
    serviceConfig.ProtectKernelModules = true;  # syscall filter to prevent module calls
    serviceConfig.ProtectKernelTunables = true;
    serviceConfig.ProtectSystem = "strict";  # makes read-only all but /dev, /proc, /sys
    serviceConfig.RestrictAddressFamilies = [
      "AF_NETLINK"
      "AF_QIPCRTR"
      "AF_UNIX"
    ];
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";  # prevents e.g. aarch64 syscalls in the event that the kernel is multi-architecture.

    # from earlier `landlock` sandboxing, i know it needs these directories:
    # - # "/"
    # - "/dev" #v modem-power + net are not enough
    # - # "/dev/modem-power"
    # - # "/dev/net"
    # - "/proc"
    # - # /run  #v can likely be reduced more
    # - "/run/dbus"
    # - "/run/NetworkManager"
    # - "/run/resolvconf"
    # - "/run/systemd"
    # - "/run/udev"
    # - "/sys"
  };

  # so that ModemManager can discover when the modem appears
  # services.udev.packages = lib.mkIf cfg.enabled [ cfg.package ];
}
