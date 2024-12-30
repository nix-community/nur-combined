# `man unbound.conf` for info on settings
# it's REALLY EASY to combine settings in a way that produce bad effects.
# generally, prefer to stay close to defaults unless there's a compelling reason to differ.
{ config, lib, ... }:
lib.optionalAttrs false  #< XXX(2024-12-29): unbound caches failed DNS resolutions, just randomly breaks connectivity daily
{
  config = lib.mkIf (!config.sane.services.hickory-dns.asSystemResolver) {
    services.resolved.enable = lib.mkForce false;

    networking.nameservers = [
      # be compatible with systemd-resolved
      # "127.0.0.53"
      # or don't be compatible with systemd-resolved, but with libc and pasta instead
      #   see <pkgs/by-name/sane-scripts/src/sane-vpn>
      "127.0.0.1"
      # enable IPv6, or don't, because having just a single name server makes monkey-patching it easier
      # "::1"
    ];
    networking.resolvconf.extraConfig = ''
      # DNS serviced by `unbound` recursive resolver
      name_servers='127.0.0.1'
    '';

    # resolve DNS recursively with Unbound.
    services.unbound.enable = lib.mkDefault true;
    services.unbound.resolveLocalQueries = false;  #< disable, so that i can manage networking.nameservers manually
    services.unbound.settings.server.interface = [ "127.0.0.1" ];
    services.unbound.settings.server.access-control = [ "127.0.0.0/8 allow" ];

    # allow control via `unbound-control`. user must be a member of the `unbound` Unix group.
    services.unbound.localControlSocketPath = "/run/unbound/unbound.ctl";

    # exempt `pool.ntp.org` from DNSSEC checks to avoid a circular dependency between DNS resolution and NTP.
    # without this, if the RTC fails, then both time and DNS are unrecoverable.
    services.unbound.settings.server.domain-insecure = config.networking.timeServers;

    # XXX(2024-12-03): BUG: during boot (before network is up), or during network blips, Unbound will
    # receive a query, fail to evaluate it, and then resolve future identical queries with a no-answers response for the next ~15m.
    # this *appears* to be some bug in Unbound's "infra-cache", as evidenced by `unbound-control flush_infra all`.
    #
    # the infra cache is a per-nameserver liveness and latency cache which Unbound uses to decide which of N applicable nameservers to route a given query to.
    #
    # there is apparently NO simple solution.
    # the closest fix is to reduce the TTL of the infra-cache (`infra-host-ttl`) so as to limit the duration of this error.
    # tried, but failed fixes:
    # - server.harden-dnssec-stripped = false
    # - services.unbound.enableRootTrustAnchor = false;  #< disable DNSSEC
    #   - server.trust-anchor-file = "${pkgs.dns-root-data}/root.key";  #< hardcode root keys instead of dynamically probing them
    # - server.disable-dnssec-lame-check = true;
    # - server.infra-keep-probing = true;  #< if unbound fails to reach a host (NS), it by default *does not try again* for 900s. keep-probing tells it to keep trying, with a backoff.
    # - server.infra-cache-min-rtt = 1000;
    # - server.infra-cache-max-rtt = 1000;
    #
    # see also:
    # - <https://forum.opnsense.org/index.php?topic=32852.0>
    # - <https://unbound.docs.nlnetlabs.nl/en/latest/reference/history/info-timeout-server-selection.html>
    #
    services.unbound.settings.server.infra-host-ttl = 30;  #< cache each NS's liveness for a max of 30s

    # perf tuning; see: <https://unbound.docs.nlnetlabs.nl/en/latest/topics/core/performance.html>
    # resource usage:
    # - defaults (num-threads = 1; so-{rcvbuf,sndbuf} = 0, prefetch = false): 12.7M memory usage
    # - num-threads = 2: 17.2M memory usage
    # - num-threads = 4: 26.2M memory usage
    # - num-threads = 4; so-{rcvbuf,sndbuf}=4m: 26.7M memory usage
    # - prefetch = true: no increased memory; supposed 10% increase in traffic
    #
    # # i suspect most operations are async; the only serialized bits are either CPU or possibly local IO (i.e. syscalls to write sockets).
    # # threading is probably only rarely helpful
    # services.unbound.settings.server.num-threads = 4;
    #
    # higher so-rcvbuf means less likely to drop client queries...
    # default is `cat /proc/sys/net/core/wmem_default`, i.e. 208k
    # services.unbound.settings.server.so-rcvbuf = "1m";
    # services.unbound.settings.server.so-sndbuf = "1m";
    #
    # `prefetch`: prefetch RRs which are about to expire from the cache, to keep them primed.
    # services.unbound.settings.server.prefetch = true;

    # if a resolution fails, or takes excessively long, reply with expired cache entries
    # see: <https://unbound.docs.nlnetlabs.nl/en/latest/topics/core/serve-stale.html#rfc-8767>
    services.unbound.settings.server.serve-expired = true;
    services.unbound.settings.server.serve-expired-ttl = 86400;  #< don't serve any records more outdated than this
    services.unbound.settings.server.serve-expired-client-timeout = 2800;  #< only serve expired records if the client has been waiting this long, ms

    # `cache-max-negative-ttl`: intended to limit damage during networking flakes, but instead seems to cause unbound to cache error responses it *wouldn't* otherwise cache
    # services.unbound.settings.server.cache-max-negative-ttl = 60;

    # `user-caps-for-id`: randomizes casing to avoid spoofing, but causes unbound to reply with no results to queries after boot (likely a infra-cache issue)
    # services.unbound.settings.server.use-caps-for-id = true;
  };
}

