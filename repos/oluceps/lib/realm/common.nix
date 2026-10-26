{
  config,
  lib,
  pkgs,
  cfg,
}:
let
  # One static binary covers the socket bridges and container adapters. It has no interpreter and no library dependencies, so the
  # same artifact also runs inside container images.
  helper = cfg.helperPackage;
  resolve =
    (import ./endpoints.nix {
      inherit lib;
      catalog = cfg.serviceDiscovery.catalog;
    }).resolve;
  # systemd-socket-proxyd bridges one systemd socket to a plain TCP or Unix
  # target. It is what connects a workload-local loopback address to an
  # authenticated socket, and it always runs inside a private namespace.
  proxy = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd";
  # socket-proxyd splits the target at the last colon and hands the host part to
  # getaddrinfo, so bracketed IPv6 literals must lose their brackets here.
  proxyTarget =
    target:
    let
      ipv6 = builtins.match "[[]([^]]+)[]]:([0-9]+)" target;
    in
    if ipv6 == null then target else "${builtins.elemAt ipv6 0}:${builtins.elemAt ipv6 1}";
  # Naming contract: realm-<name> is the proxy account of workload <name>,
  # w.unit is the application, and /run/realm/<name> is the only runtime path
  # the two sides share.
  appName = w: lib.removeSuffix ".service" w.unit;
  proxyUser = name: "realm-${name}";
  base = name: "/run/realm/${name}";
  egressPath = name: route: "${base name}/egress/${route}.sock";
  ingressPath = name: route: "${base name}/ingress/${route}.sock";
  # Baseline sandbox for every unit this module creates. Proxy, adapter and
  # helper processes need no privileges, no writable system paths and only Unix
  # and IP sockets, so none of these settings has to be relaxed per workload.
  #
  # systemd does not mount PrivateTmp's tmpfs for a unit that joins another
  # unit's network namespace: the unit then keeps the host /tmp, which
  # ProtectSystem=strict has made read-only. An explicit tmpfs keeps /tmp
  # private and writable for every generated unit, including the ones that join
  # realm-net-<name>, and hides host /tmp contents from them. The mode matches
  # what PrivateTmp would use, because applications such as ncps write there as
  # an unprivileged user.
  privateTmp = "/tmp:mode=1777";
  # ghostunnel drains open connections on SIGTERM. An idle keep-alive peer holds
  # a connection until --max-conn-lifetime, so without this bound a restart waits
  # for systemd's stop timeout and is killed instead of exiting cleanly.
  drainTimeout = "15s";
  hardened = (import ../proxy-hardening.nix) // {
    NoNewPrivileges = true;
    CapabilityBoundingSet = "";
    PrivateTmp = true;
    TemporaryFileSystem = [ privateTmp ];
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateDevices = true;
    RestrictSUIDSGID = true;
    RestrictNamespaces = true;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    SystemCallArchitectures = "native";
    UMask = "0077";
    Restart = "on-failure";
    RestartSec = "3s";
  };
  # Socket ownership. The socket user accepts connections, the group names the
  # local peer allowed to connect, and mode 0660 lets exactly those two parties
  # through.
  activation = user: group: fd: {
    SocketUser = user;
    SocketGroup = group;
    SocketMode = "0660";
    RemoveOnStop = true;
    FileDescriptorName = fd;
  };
in
{
  inherit
    helper
    resolve
    proxy
    proxyTarget
    appName
    proxyUser
    base
    egressPath
    ingressPath
    privateTmp
    drainTimeout
    hardened
    activation
    ;
}
