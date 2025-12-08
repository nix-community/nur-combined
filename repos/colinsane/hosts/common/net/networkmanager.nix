{ config, lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  # systemd-networkd-wait-online.service reliably fails on lappy. docs don't match behavior. shit software.
  # XXX(2025-07-18): `systemd-networkd-wait-online.service` also fails on desko (timeout).
  systemd.network.wait-online.enable = false;

  networking.networkmanager.package = pkgs.networkmanager-split.daemon.overrideAttrs (upstream: {
    # postPatch = (upstream.postPatch or "") + ''
    #   substituteInPlace src/{core/org.freedesktop.NetworkManager,nm-dispatcher/nm-dispatcher}.conf --replace-fail \
    #     'user="root"' 'user="networkmanager"'
    # '';
    postInstall = (upstream.postInstall or "") + ''
      # allow the bus to owned by either root or networkmanager users
      # use the group here, that way ordinary users can be elevated to control networkmanager
      # (via e.g. `nmcli`)
      confs=(nm-dispatcher.conf)
      confs+=(org.freedesktop.NetworkManager.conf)
      for f in "''${confs[@]}" ; do
        substitute $out/share/dbus-1/system.d/$f \
          $out/share/dbus-1/system.d/networkmanager-$f \
          --replace-fail 'user="root"' 'group="networkmanager"'
      done

      # remove unused services to prevent any unexpected interactions
      rm $out/etc/systemd/system/{nm-cloud-setup.service,nm-cloud-setup.timer,nm-priv-helper.service}
    '';
  });

  # fixup the services to run as `networkmanager` and with less permissions
  systemd.services.NetworkManager = {
    serviceConfig.RuntimeDirectory = "NetworkManager";  #< tells systemd to create /run/NetworkManager
    # serviceConfig.StateDirectory = "NetworkManager";  #< tells systemd to create /var/lib/NetworkManager
    serviceConfig.User = "networkmanager";
    serviceConfig.Group = "networkmanager";
    serviceConfig.AmbientCapabilities = [
      "CAP_KILL"  #< required, else `nmcli d disconnect blah` says "Unable to determine UID of the request"
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
      "CAP_NET_BIND_SERVICE"

      # "CAP_DAC_OVERRIDE"
      # "CAP_SYS_MODULE"
      # "CAP_AUDIT_WRITE"  #< allow writing to the audit log (optional)
      # "CAP_KILL"
    ];
    serviceConfig.CapabilityBoundingSet = [
      "CAP_KILL"  #< required, else `nmcli d disconnect blah` says "Unable to determine UID of the request"
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"  #< required, else `libndp: ndp_sock_open: Failed to create ICMP6 socket.`
      "CAP_NET_BIND_SERVICE"  #< this *does* seem to be necessary, though i don't understand why. DHCP?

      # "CAP_DAC_OVERRIDE"
      # "CAP_SYS_MODULE"
      # "CAP_AUDIT_WRITE"  #< allow writing to the audit log (optional)
      # "CAP_KILL"
    ];
    serviceConfig.LockPersonality = true;
    serviceConfig.NoNewPrivileges = true;
    serviceConfig.MemoryDenyWriteExecute = true;
    serviceConfig.PrivateDevices = true;  # remount /dev with just the basics, syscall filter to block @raw-io
    serviceConfig.PrivateIPC = true;
    serviceConfig.PrivateTmp = true;
    # serviceConfig.PrivateUsers = true;  #< BREAKS NetworkManager (presumably, it causes a new user namespace, breaking CAP_NET_ADMIN & others).  "platform-linux: do-change-link[3]: failure 1 (Operation not permitted)"
    serviceConfig.ProtectClock = true;  # syscall filter to prevent changing the RTC
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;  # makes empty: /home, /root, /run/user
    serviceConfig.ProtectHostname = true;  # probably not upstreamable: prevents changing hostname
    serviceConfig.ProtectKernelLogs = true;  # disable /proc/kmsg, /dev/kmsg
    serviceConfig.ProtectKernelModules = true;  # syscall filter to prevent module calls (probably not upstreamable: NM will want to load modules like `ppp`)
    # serviceConfig.ProtectKernelTunables = true;  # causes errors/warnings when opening files in /proc/sys/net/...; also breaks IPv6 SLAAC / link-local address creation!
    serviceConfig.ProtectProc = "invisible";
    serviceConfig.ProcSubset = "all";
    serviceConfig.ProtectSystem = "strict";  # makes read-only: all but /dev, /proc, /sys.
    serviceConfig.RemoveIPC = true;
    serviceConfig.RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"  # breaks near DHCP without this
      "AF_PACKET"  # for DHCP
      "AF_UNIX"
      # AF_ALG ?
      # AF_BLUETOOTH ?
      # AF_BRIDGE ?
    ];
    serviceConfig.RestrictNamespaces = true;
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";  # prevents e.g. aarch64 syscalls in the event that the kernel is multi-architecture.
    serviceConfig.SystemCallFilter = [
      "@system-service"
      # TODO: restrict SystemCallFilter more aggressively
    ];
    # TODO: restrict `DeviceAllow`
    # from earlier `landlock` sandboxing, i know it needs these directories:
    # - "/proc/net"
    # - "/proc/sys/net"
    # - "/run/NetworkManager"
    # - "/run/systemd"  # for hickory-dns-nmhook
    # - "/run/udev"
    # - # "/run/wg-home.priv"
    # - "/sys/class"
    # - "/sys/devices"
    # - "/var/lib/NetworkManager"
    # - "/var/lib/hickory-dns"  #< for hickory-dns-nmhook
    # - "/run/systemd"
  };

  systemd.services.NetworkManager-wait-online = {
    serviceConfig.User = "networkmanager";
    serviceConfig.Group = "networkmanager";
  };

  # fix NetworkManager-dispatcher to actually run as a daemon,
  # and sandbox it a bit
  systemd.services.NetworkManager-dispatcher = {
    #VVV so that /var/lib/hickory-dns will exist (the hook needs to write here).
    # but this creates a cycle: hickory-dns-localhost > network.target > NetworkManager-dispatcher > hickory-dns-localhost.
    # (seemingly) impossible to remove the network.target dep on NetworkManager-dispatcher.
    # before would be to have the dispatcher not write hickory-dns files
    # but rather just its own, and create a .path unit which restarts hickory-dns appropriately.
    # after = [ "hickory-dns-localhost.service" ];
    # serviceConfig.ExecStart = [
    #   ""  # first blank line is to clear the upstream `ExecStart` field.
    #   "${cfg.package}/libexec/nm-dispatcher --persist"  # --persist is needed for it to actually run as a daemon
    # ];
    # serviceConfig.Restart = "always";
    # serviceConfig.RestartSec = "1s";

    # serviceConfig.DynamicUser = true;  #< not possible, else we lose group perms (so can't write to `hickory-dns`'s files in the nm hook)
    serviceConfig.User = "networkmanager";  # TODO: should arguably use `DynamicUser`
    serviceConfig.Group = "networkmanager";
    serviceConfig.LockPersonality = true;
    serviceConfig.NoNewPrivileges = true;
    serviceConfig.PrivateDevices = true;  # remount /dev with just the basics, syscall filter to block @raw-io
    serviceConfig.PrivateIPC = true;
    serviceConfig.PrivateTmp = true;
    serviceConfig.PrivateUsers = true;
    serviceConfig.ProtectClock = true;  # syscall filter to prevent changing the RTC
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;  # makes empty: /home, /root, /run/user
    serviceConfig.ProtectHostname = true;  # probably not upstreamable: prevents changing hostname
    serviceConfig.ProtectKernelLogs = true;  # disable /proc/kmsg, /dev/kmsg
    serviceConfig.ProtectKernelModules = true;  # syscall filter to prevent module calls
    serviceConfig.ProtectKernelTunables = true;
    serviceConfig.ProtectSystem = "full";  # makes read-only: /boot, /etc/, /usr. `strict` isn't possible due to hickory-dns hook
    serviceConfig.RestrictAddressFamilies = [
      "AF_UNIX"  # required, probably for dbus or systemd connectivity
    ];
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";  # prevents e.g. aarch64 syscalls in the event that the kernel is multi-architecture.
  };

  # harden wpa_supplicant (used by NetworkManager)
  systemd.services.wpa_supplicant = {
    serviceConfig.User = "networkmanager";
    serviceConfig.Group = "networkmanager";
    serviceConfig.AmbientCapabilities = [
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
    ];
    serviceConfig.LockPersonality = true;
    serviceConfig.NoNewPrivileges = true;
    # serviceConfig.PrivateDevices = true;  # untried, not likely to work. remount /dev with just the basics, syscall filter to block @raw-io
    serviceConfig.PrivateIPC = true;
    serviceConfig.PrivateTmp = true;
    # serviceConfig.PrivateUsers = true;  #< untried, not likely to work
    serviceConfig.ProtectClock = true;  # syscall filter to prevent changing the RTC
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;  # makes empty: /home, /root, /run/user
    serviceConfig.ProtectHostname = true;  # prevents changing hostname
    serviceConfig.ProtectKernelLogs = true;  # disable /proc/kmsg, /dev/kmsg
    serviceConfig.ProtectKernelModules = true;  # syscall filter to prevent module calls
    serviceConfig.ProtectKernelTunables = true;  #< N.B.: i think this makes certain /proc writes fail
    serviceConfig.ProtectSystem = "strict";  # makes read-only: all but /dev, /proc, /sys.
    serviceConfig.RestrictAddressFamilies = [
      "AF_INET"  #< required
      "AF_INET6"
      "AF_NETLINK"  #< required
      "AF_PACKET"  #< required
      "AF_UNIX"  #< required (wpa_supplicant wants to use dbus)
    ];
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";  # prevents e.g. aarch64 syscalls in the event that the kernel is multi-architecture.

    # from earlier `landlock` sandboxing, i know it needs only these paths:
    # - "/dev/net"
    # - "/dev/rfkill"
    # - "/proc/sys/net"
    # - "/sys/class/net"
    # - "/sys/devices"
    # - "/run/systemd"
  };

  networking.networkmanager.settings = {
    # docs: `man 5 NetworkManager.conf`
    # keyfile.path = where networkmanager should look for connection credentials
    keyfile.path = "/var/lib/NetworkManager/system-connections";

    # wifi.backend = "wpa_supplicant";  #< default
    # wifi.scan-rand-mac-address = true;  #< default

    # logging.audit = false;  #< default
    logging.level = "INFO";

    # main.dhcp = "internal";  #< default
    # main.dns controls what to do when NM gets a DNS server via DHCP
    # - "default": NM manages /etc/resolv.conf itself.
    # - "none": NM doesn't manage /etc/resolv.conf, but does populate /run/NetworkManager/resolv.conf with DHCP settings
    # - "systemd-resolved": tell systemd-resolved about it, and point /run/NetworkManager/resolv.conf -> systemd
    #   - without this, systemd-resolved won't be able to resolve anything (because it has no upstream servers)
    # - (empty): perform a best-guess for how to manage /etc/resolv.conf
    #   -> if /etc/resolv.conf is a symlink to systemd-resolved, then behaves as "systemd-resolved".
    #   -> else, behaves as "default".
    # note that NM's resolv.conf isn't (necessarily) /etc/resolv.conf -- that is managed by nixos (via symlinking)
    main.dns = let
      dns = if config.services.resolved.enable then
        "systemd-resolved"
      else if
        (config.sane.services.hickory-dns.enable && config.sane.services.hickory-dns.asSystemResolver)
        || (config.services.unbound.enable && config.services.unbound.resolveLocalQueries)
        || config.services.bind.enable  # bind config isn't easily inspectable; assume that it's acting as local resolver
      then
        "none"
      else
        # omitting the option instructs NM to do a "best guess".
        # this is nearly equivalent to "default", however NM will do checks like "is /etc/resolv.conf a symlink to systemd-resolved", etc,
        # to actually try to understand the environment.
        null
      ;
    in lib.mkIf (dns != null) dns;
    main.systemd-resolved = false;
  };
  environment.etc."NetworkManager/system-connections".source = "/var/lib/NetworkManager/system-connections";

  # the default backend is "wpa_supplicant".
  # wpa_supplicant reliably picks weak APs to connect to.
  # see: <https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/474>
  # iwd is an alternative that shouldn't have this problem
  # docs:
  # - <https://nixos.wiki/wiki/Iwd>
  # - <https://iwd.wiki.kernel.org/networkmanager>
  # - `man iwd.config`  for global config
  # - `man iwd.network` for per-SSID config
  # use `iwctl` to control
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.wireless.iwd.enable = true;
  # networking.wireless.iwd.settings = {
  #   # auto-connect to a stronger network if signal drops below this value
  #   # bedroom -> bedroom connection is -35 to -40 dBm
  #   # bedroom -> living room connection is -60 dBm
  #   General.RoamThreshold = "-52";  # default -70
  #   General.RoamThreshold5G = "-52";  # default -76
  # };

  # allow networkmanager to control systemd-resolved,
  # which it needs to do to apply new DNS settings when using systemd-resolved.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("networkmanager") && action.id.indexOf("org.freedesktop.resolve1.") == 0) {
        return polkit.Result.YES;
      }
    });
  '';

  users.users.networkmanager = {
    isSystemUser = true;
    group = "networkmanager";
    extraGroups = [ "hickory-dns" ];
  };

  # there is, unfortunately, no proper interface by which to plumb wpa_supplicant into the NixOS service, except by overlay.
  nixpkgs.overlays = [(self: super: {
    wpa_supplicant = super.wpa_supplicant.overrideAttrs (upstream: {
      # postPatch = (upstream.postPatch or "") + ''
      #   substituteInPlace wpa_supplicant/dbus/dbus-wpa_supplicant.conf --replace-fail \
      #     'user="root"' 'user="networkmanager"'
      # '';
      postInstall = (upstream.postInstall or "") + ''
        substitute $out/share/dbus-1/system.d/dbus-wpa_supplicant.conf \
          $out/share/dbus-1/system.d/networkmanager-wpa_supplicant.conf \
          --replace-fail 'user="root"' 'group="networkmanager"'
      '';

      postFixup = (upstream.postFixup or "") + ''
        # remove unused services to avoid unexpected interactions
        rm $out/etc/systemd/system/{wpa_supplicant-nl80211@,wpa_supplicant-wired@,wpa_supplicant@}.service
      '';
    });
  })];
}
