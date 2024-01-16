{ ... }:
{
  # use systemd's stub resolver.
  # /etc/resolv.conf isn't sophisticated enough to use different servers per net namespace (or link).
  # instead, running the stub resolver on a known address in the root ns lets us rewrite packets
  # in the ovnps namespace to use the provider's DNS resolvers.
  # a weakness is we can only query 1 NS at a time (unless we were to clone the packets?)
  # there also seems to be some cache somewhere that's shared between the two namespaces.
  # i think this is a libc thing. might need to leverage proper cgroups to _really_ kill it.
  # - getent ahostsv4 www.google.com
  # - try fix: <https://serverfault.com/questions/765989/connect-to-3rd-party-vpn-server-but-dont-use-it-as-the-default-route/766290#766290>
  services.resolved.enable = true;
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
  # TODO: run a separate recursive resolver in each namespace.
  services.nscd.enableNsncd = true;
}
