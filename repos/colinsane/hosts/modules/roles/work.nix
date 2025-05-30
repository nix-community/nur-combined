{ config, lib, ... }:
{
  options.sane.roles.work = with lib; mkOption {
    type = types.bool;
    default = false;
    description = ''
      programs/services used when working for hire.
    '';
  };

  config = lib.mkIf config.sane.roles.work {
    ### TAILSCALE
    # first run:
    # - `sudo tailscale login --hostname $myHostname`
    sane.persist.sys.byStore.private = [
      { user = "root"; group = "root"; mode = "0700"; path = "/var/lib/tailscale"; method = "bind"; }
    ];
    services.tailscale.enable = true;
    # services.tailscale.useRoutingFeatures = "client";
    services.tailscale.extraSetFlags = [
      "--accept-routes"
      # "--operator=colin"  #< this *should* allow non-root control, but fails: <https://github.com/tailscale/tailscale/issues/16080>
    ];
    services.tailscale.extraDaemonFlags = [
      "-verbose" "7"
    ];
    services.bind.extraConfig = ''
      include "${config.sops.secrets."tailscale-work-zones-bind.conf".path}";
    '';
    systemd.services.tailscaled = {
      # systemd hardening (systemd-analyze security tailscaled.service)
      serviceConfig.AmbientCapabilities = "CAP_NET_ADMIN";
      serviceConfig.CapabilityBoundingSet = "CAP_NET_ADMIN";
      serviceConfig.LockPersonality = true;
      serviceConfig.MemoryDenyWriteExecute = true;
      serviceConfig.NoNewPrivileges = true;

      serviceConfig.ProtectClock = true;
      serviceConfig.ProtectControlGroups = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectHostname = true;
      serviceConfig.ProtectKernelLogs = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectKernelTunables = true;
      serviceConfig.ProtectProc = "invisible";
      serviceConfig.ProtectSystem = "strict";  # makes read-only: all but /dev, /proc, /sys.
      serviceConfig.ProcSubset = "pid";

      # serviceConfig.PrivateIPC = true;
      serviceConfig.PrivateTmp = true;

      # serviceConfig.RemoveIPC = true;  #< does not apply to root
      serviceConfig.RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
      # #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
      # # see `systemd-analyze filesystems` for a full list
      serviceConfig.RestrictFileSystems = "@application @basic-api @common-block";
      serviceConfig.RestrictRealtime = true;
      serviceConfig.RestrictSUIDSGID = true;
      serviceConfig.SystemCallArchitectures = "native";
      serviceConfig.SystemCallFilter = [
        "@system-service"
        "@sandbox"
        "~@chown"
        "~@cpu-emulation"
        "~@keyring"
      ];
      serviceConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
      serviceConfig.DeviceAllow = "/dev/net/tun";  #< TODO: enable "userspace networking" tailscale option, to remove this?
      serviceConfig.RestrictNamespaces = true;
    };

    sane.programs.guiApps.suggestedPrograms = [
      "slack"
      "zoom-us"
    ];
  };
}
