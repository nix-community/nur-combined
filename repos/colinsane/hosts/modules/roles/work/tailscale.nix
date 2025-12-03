# first run:
# - `sudo tailscale login --hostname $myHostname`
#
# N.B.: manage with:
# - `systemctl {stop,start} tailscaled`
#   NOT `tailscale {down,up}`
#   the latter isn't compatible with my ip routing patches, below
{ config, lib, pkgs, ... }:
let
  ip = lib.getExe' pkgs.iproute2 "ip";
  ### TAILSCALE ROUTING
  # - tailscale maintains the following `ip rule`s:
  #   - 5210: from all fwmark 0x80000/0xff0000 lookup main
  #   - 5230: from all fwmark 0x80000/0xff0000 lookup default
  #   - 5250: from all fwmark 0x80000/0xff0000 unreachable
  #   - 5270: from all lookup 52
  # - tailscale _always_ adds its wireguard peers (100.64.0.0/10) to table 52
  #   - view with: `ip route showq table 52`
  # - tailscale _conditionally_ adds routes (to _any_ destination address) _via_ these peers, to table 52.
  #   - THIS is what the `--accept-routes` argument does.
  #   - these routes are critical even for DNS.
  #   - `--accept-routes` seems to impact both tailscale-internal behavior AND iptables;
  #     hence it's NOT possible to omit `--accept-routes` and then manually define the routes i want.
  # - peer-advertised routes (via `--accept-routes`) often conflict with pre-existing local routes.
  #   e.g. in the 10.0.0.0/8 range.
  # - official way to handle conflicting routes is by manually making higher-precedence ip rules for what i care about:
  #   - <https://tailscale.com/kb/1023/troubleshooting#lan-traffic-prioritization-with-overlapping-subnet-routes>
  # - workarounds for conflicting routes is to provide tailscale a custom `ip` tool for it to shell out to:
  #   - <https://github.com/tailscale/tailscale/issues/6231#issuecomment-1420912939>
  #
  # HOW I CONFIGURE TAILSCALE ROUTING:
  # - provide `--accept-routes`
  # - override the `ip` tool such that tailscale doesn't actually modify the routing table.
  # - explicitly configure the range of routes i actually want.
  routableSubnets = [
    # linux routing is "most specific wins".
    # but overlapping routes are still problematic,
    # because during interface bringup a packet might temporarily be routed to a place it wouldn't during nominal operations
    #
    # tailscale networks seem to mostly use these IPv4 reserved address ranges:
    # 0.0.0.0/8
    # 10.0.0.0/8
    # 100.64.0.0/10
    #
    # "10.0.0.0/8"
    # "10.1.0.0/16"   # - 10.1.255.255
    "10.2.0.0/15"   # - 10.3.255.255
    "10.4.0.0/14"   # - 10.7.255.255
    "10.8.0.0/13"   # - 10.15.255.255
    "10.16.0.0/12"  # - 10.31.255.255
    "10.32.0.0/11"  # - 10.63.255.255
    "10.64.0.0/13"  # - 10.71.255.255
    "10.72.0.0/14"  # - 10.75.255.255
    "10.76.0.0/15"  # - 10.77.255.255
    # XXX: 10.78.0.0 - 10.78.255.255 gap for my home network
    # "10.79.0.0/16"  # - 10.79.255.255
    "10.80.0.0/13"  # - 10.87.255.255
    "10.88.0.0/13"  # - 10.95.255.255
    "10.96.0.0/11"  # - 10.127.255.255
    "10.128.0.0/9"  # - 10.255.255.255
    "100.64.0.0/10"
    "192.168.0.0/16"
  ];
  tailscale = let
    iproute2' = pkgs.callPackage ./tailscale-iproute2 { };
    # tailscale package wraps binaries with `--prefix PATH ${iproute2}/bin`.
    # tailscale takes 1m to compile, 5m to run tests => slow to iterate.
    # instead, remove iproute2 from tailscale,
    # then re-wrap the binaries with my custom iproute2, separately.
    tailscaleNoIproute2 = pkgs.tailscale.override {
      iproute2 = null;
      makeWrapper = pkgs.makeBinaryWrapper;  #< only BinaryWrapper handles `--inherit-argv0` correctly
    };
  in pkgs.stdenvNoCC.mkDerivation {
    inherit (tailscaleNoIproute2) pname version;
    nativeBuildInputs = [
      pkgs.makeBinaryWrapper  #< only BinaryWrapper handles `--inherit-argv0` correctly
    ];
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out

      mkdir -p $out/lib/systemd/system
      substitute ${tailscaleNoIproute2}/lib/systemd/system/tailscaled.service $out/lib/systemd/system/tailscaled.service \
        --replace-fail ${tailscaleNoIproute2} $out
      ln -s ${tailscaleNoIproute2}/share $out/share

      mkdir -p $out/bin
      ln -s ${tailscaleNoIproute2}/bin/get-authkey $out/bin/get-authkey
      ln -s tailscaled $out/bin/tailscale
      ln -s ${tailscaleNoIproute2}/bin/tailscaled $out/bin/tailscaled
      ln -s ${tailscaleNoIproute2}/bin/tsidp $out/bin/tsidp

      wrapProgram $out/bin/tailscaled \
        --inherit-argv0 \
        --prefix PATH : ${lib.makeBinPath [ iproute2' ]}
    '';

    inherit (tailscaleNoIproute2) meta;
    passthru = tailscaleNoIproute2.passthru // {
      iproute2 = iproute2';
    };
  };
in
{
  config = lib.mkIf config.sane.roles.work (lib.mkMerge [
    {
      sane.persist.sys.byStore.private = [
        { user = "root"; group = "root"; mode = "0700"; path = "/var/lib/tailscale"; method = "bind"; }
      ];
      services.tailscale.enable = true;

      services.tailscale.package = tailscale;
      systemd.services.tailscaled.environment.TS_DEBUG_USE_IP_COMMAND = "1";

      # "statically" configure the routes to tailscale.
      # tailscale doesn't use the kernel wireguard module,
      # but a userspace `wireguard-go` (coupled with `/dev/net/tun`, or a pure
      # pasta-style TCP/UDP userspace dev).
      #
      # it therefore appears as an "unmanaged" device to network managers like systemd-networkd.
      # in order to configure routes, we have to script it.
      systemd.services.tailscaled.serviceConfig.ExecStartPost = [
        (pkgs.writeShellScript "tailscaled-add-routes" ''
          while ! ${lib.getExe' tailscale "tailscale"} status ; do
            echo "tailscale not ready"
            sleep 2
          done
          for addr in ${lib.concatStringsSep " " routableSubnets}; do
            (set -x ; ${ip} route add table main "$addr" dev tailscale0 scope global)
          done
        '')
      ];
      systemd.services.tailscaled.preStop = ''
        for addr in ${lib.concatStringsSep " " routableSubnets}; do
          (set -x ; ${ip} route del table main "$addr" dev tailscale0 scope global) || true
        done
      '';
      # systemd.network.networks."50-tailscale" = {
      #   # see: `man 5 systemd.network`
      #   matchConfig.Name = "tailscale0";
      #   routes = [
      #     # {
      #     #   Scope = "global";
      #     #   # 0.0.0.0/8 is a reserved-for-local-network range in IPv4
      #     #   Destination = "0.0.0.0/8";
      #     # }
      #     {
      #       Scope = "global";
      #       # Scope = "link";
      #       # 10.0.0.0/8 is a reserved-for-private-networks range in IPv4
      #       Destination = "10.0.0.0/8";
      #     }
      #     {
      #       Scope = "global";
      #       # Scope = "link";
      #       # 100.64.0.0/10 is a reserved range in IPv4
      #       Destination = "100.64.0.0/10";
      #     }
      #   ];
      #   # RequiredForOnline => should `systemd-networkd-wait-online` fail if this network can't come up?
      #   linkConfig.RequiredForOnline = false;
      #   linkConfig.Unmanaged = lib.mkForce false;  #< tailscale nixos module declares this as unmanaged
      # };

      # services.tailscale.useRoutingFeatures = "client";
      services.tailscale.extraSetFlags = [
        # --accept-routes does _two_ things:
        # 1. allows tailscale to discover, internally, how to route to peers-of-peers.
        # 2. instructs tailscale to tell the kernel to route discovered routes through the tailscale0 device.
        # even if i disable #2, i still need --accept-routes to provide #1.
        "--accept-routes"
        # "--operator=colin"  #< this *should* allow non-root control, but fails: <https://github.com/tailscale/tailscale/issues/16080>
        # lock the preferences i care about, because even if they're default i think they _might_ be conditional on admin policy:
        # --accept-dns=false:
        # 1. i manage DNS (/etc/resolv.conf) manually, with BIND/nixos
        # 2. `tailscale dns query ...` works only if `--accept-dns` is set FALSE.
        #    maybe because `--accept-dns=true` causes tailscaled to fail to write resolvconf, and then it aborts, or something...
        "--accept-dns=false"
        # "--accept-routes=false"
        "--advertise-connector=false"
        "--advertise-exit-node=false"
        # "--auto-update=false"  # "automatic updates are not supported on this platform"
        "--ssh=false"
        "--update-check=false"
        "--webclient=false"
      ];
      services.tailscale.extraDaemonFlags = [
        "-verbose" "7"
      ];
    }

    {
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
        serviceConfig.DeviceAllow = "/dev/net/tun";
        serviceConfig.RestrictNamespaces = true;
      };
    }

    (lib.mkIf config.services.bind.enable {
      # make DNS resolvable, if using BIND
      sops.secrets."tailscale-work-zones-bind.conf".owner = "named";
      services.bind.extraConfig = ''
        include "${config.sops.secrets."tailscale-work-zones-bind.conf".path}";
      '';
    })

    (lib.mkIf config.services.kresd.enable {
      # make DNS resolvable, if using kresd
      sops.secrets."tailscale-work-zones-kresd.conf".owner = "knot-resolver";

      systemd.services."kresd@".serviceConfig = let
        package = config.services.kresd.package;
      in {
        ExecStart = lib.mkForce [
          ""  #< clear previous assignment
          (
            # override default CLI so as to inject `-c` for secret config portion
            # TODO: refactor for cleaner integration with hosts/common/net/dns/kresd.nix
            "${package}/bin/kresd --noninteractive"
            + " -c ${package}/lib/knot-resolver/distro-preconfig.lua"
            + " -c /etc/knot-resolver/kresd.conf"
            + " -c ${config.sops.secrets."tailscale-work-zones-kresd.conf".path}"
          )
        ];
      };
    })
  ]);
}
