{ config, lib, pkgs, ... }:
let
  cfg = config.services.hardenedUnbound;
in
{
  options.services.hardenedUnbound = {
    enable = lib.mkEnableOption "Matt's hardened Unbound DNS server";
  };

  config = lib.mkIf cfg.enable {
    services.unbound = {
      package = pkgs.unbound-full;
      resolveLocalQueries = false; # DEBUG
      enable = true;
      localControlSocketPath = "/run/unbound/unbound.ctl";
      settings = {
        #  # Where are we serving?
        server = {
          interface = "0.0.0.0@53";
          access-control = [
            "192.168.0.0/16 allow"
            "127.0.0.0/8 allow"
            "192.168.0.0/16 allow"
            "10.0.0.0/8 allow"
          ];
          private-address = [
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
          ];
          do-ip4 = true;
          do-ip6 = false;
          do-tcp = true;
          do-udp = true;

          # Logging
          verbosity = 0;
          log-queries = false;
          log-replies = false;
          log-servfail = false;
          log-local-actions = false;
          #logfile = "";
          num-threads = 1; # More than 1 screwed up logging on OpenBSD
          # IIRC ncreasing threads multiplies cache sizes as well

          # Gather stats about the cache
          extended-statistics = true; # shows more info about the cache
          statistics-cumulative = true; # doesn't flush stats after every check

          # Hardening
          aggressive-nsec = true;
          harden-algo-downgrade = true;
          harden-below-nxdomain = true;
          harden-dnssec-stripped = true;
          harden-glue = true;
          harden-large-queries = true;
          harden-short-bufsize = true;
          hide-identity = true;
          hide-version = true;
          ipsecmod-enabled = false;
          #module-config = "validator iterator";
          prefetch = true;
          prefetch-key = true;
          qname-minimisation = true;
          qname-minimisation-strict = false;
          rrset-roundrobin = true;
          use-caps-for-id = true;
          val-clean-additional = true;
          val-log-level = 2;

          # Caching
          # Buffer size for UDP port 53
          so-rcvbuf = "1m";
          # Increase cache memory
          rrset-cache-size = "512m";
          neg-cache-size = "256m";
          msg-cache-size = "256m";
          key-cache-size = "256m";
          serve-expired = true;
          # Speed
          infra-cache-slabs = 1;
          key-cache-slabs = 1;
          msg-cache-slabs = 1;
          rrset-cache-slabs = 1;

          # Misc
          so-reuseport = true;
          # libevent
          outgoing-range = 8192;
          num-queries-per-thread = 4096;
        };
        forward-zone = [
          {
            forward-tls-upstream = true;
            name = ".";
            forward-addr = [
              # Quad9 - https://www.quad9.net/
              "2620:fe::fe@853#dns.quad9.net"
              "9.9.9.9@853#dns.quad9.net"
              "2620:fe::9@853#dns.quad9.net"
              "149.112.112.112@853#dns.quad9.net"

              # Cloudflare - https://www.cloudflare.com/dns/
              "2606:4700:4700::1112@853#cloudflare-dns.com"
              "1.1.1.2@853#cloudflare-dns.com"
              "2606:4700:4700::1002@853#cloudflare-dns.com"
              "1.0.0.2@853#cloudflare-dns.com"

              # UncensoredDNS - https://blog.uncensoreddns.org/
              "2001:67c:28a4::@853#anycast.censurfridns.dk"
              "91.239.100.100@853#anycast.censurfridns.dk"
              "2a01:3a0:53:53::@853#unicast.censurfridns.dk"
              "89.233.43.71@853#unicast.censurfridns.dk"

              # TODO: alternative DNS registrars

              ## EasyHandshake.com - https://easyhandshake.com/
              #"165.22.151.242@853#easyhandshake.com"
              ## OpenNIC
              #"2001:19f0:5c01:542:5400:03ff:fe1b:5a17@853#ns1.il.us.dns.opennic.glue"
              #"45.63.66.176@853#ns1.il.us.dns.opennic.glue"
            ];
          }
        ];
      };
    };
  };
}
