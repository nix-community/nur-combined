# things to consider when changing these parameters:
# - temporary VPN access (`sane-vpn up ...`)
# - servo `ovpns` namespace (it *relies* on /etc/resolv.conf mentioning 127.0.0.53)
# - jails: `firejail --net=br-ovpnd-us --noprofile --dns=46.227.67.134 ping 1.1.1.1`
#
# components:
# - /etc/nsswitch.conf:
#   - glibc uses this to provide `getaddrinfo`, i.e. host -> ip address lookup
#     call directly with `getent ahostsv4 www.google.com`
#   - `nss` (a component of glibc) is modular: names mentioned in that file are `dlopen`'d (i think that's the mechanism)
#     in NixOS, that means _they have to be on LDPATH_.
#   - `nscd` is used by NixOS simply to proxy nss requests.
#      here, /etc/nsswitch.conf consumers contact nscd via /var/run/nscd/socket.
#      in this way, only `nscd` needs to have the nss modules on LDPATH.
# - /etc/resolv.conf
#   - contains the DNS servers for a system.
#   - historically, NetworkManager would update this file as you switch networks.
#   - modern implementations hardcodes `127.0.0.53` and then systemd-resolved proxies everything (and caches).
#
# namespacing:
# - each namespace can use a different /etc/resolv.conf to specify different DNS servers (see `firejail --dns=...`)
# - nscd breaks namespacing: the host nscd is unaware of the guest's /etc/resolv.conf, and so direct's the guest's DNS requests to the host's servers.
#   - this is fixed by either `firejail --blacklist=/var/run/nscd/socket`, or disabling nscd altogether.
{ lib, ... }:
{
  # use systemd's stub resolver.
  # /etc/resolv.conf isn't sophisticated enough to use different servers per net namespace (or link).
  # instead, running the stub resolver on a known address in the root ns lets us rewrite packets
  # in servo's ovnps namespace to use the provider's DNS resolvers.
  # a weakness is we can only query 1 NS at a time (unless we were to clone the packets?)
  # TODO: rework servo's netns to use `firejail`, which is capable of spoofing /etc/resolv.conf.
  services.resolved.enable = true;  #< to disable, set ` = lib.mkForce false`, as other systemd features default to enabling `resolved`.
  # without DNSSEC:
  # - dig matrix.org => works
  # - curl https://matrix.org => works
  # with default DNSSEC:
  # - dig matrix.org => works
  # - curl https://matrix.org => fails
  # i don't know why. this might somehow be interfering with the DNS run on this device (trust-dns)
  services.resolved.dnssec = "false";
  networking.nameservers = [
    # use systemd-resolved resolver
    # full resolver (which understands /etc/hosts) lives on 127.0.0.53
    # stub resolver (just forwards upstream) lives on 127.0.0.54
    "127.0.0.53"
  ];

  # nscd -- the Name Service Caching Daemon -- caches DNS query responses
  # in a way that's unaware of my VPN routing, so routes are frequently poor against
  # services which advertise different IPs based on geolocation.
  # nscd claims to be usable without a cache, but in practice i can't get it to not cache!
  # nsncd is the Name Service NON-Caching Daemon. it's a drop-in that doesn't cache;
  # this is OK on the host -- because systemd-resolved caches. it's probably sub-optimal
  # in the netns and we query upstream DNS more often than needed. hm.
  # services.nscd.enableNsncd = true;

  # disabling nscd LOSES US SOME FUNCTIONALITY. in particular, only the glibc-builtin modules are accessible via /etc/resolv.conf.
  # - dns: glibc-bultin
  # - files: glibc-builtin
  # - myhostname: systemd
  # - mymachines: systemd
  # - resolve: systemd
  # in practice, i see no difference with nscd disabled.
  # disabling nscd VASTLY simplifies netns and process isolation. see explainer at top of file.
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
}
