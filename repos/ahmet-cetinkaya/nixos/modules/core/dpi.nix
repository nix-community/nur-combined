{
  lib,
  pkgs,
  ...
}: {
  services.zapret = {
    enable = true;
    udpSupport = true;
    udpPorts = [
      "443"
      "50000:50099"
    ];

    params = [
      "--filter-udp=50000-50099"
      "--filter-l7=discord,stun"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
      "--new"

      "--filter-tcp=443"
      "--hostlist-domains=discord.com,discord.gg,discordapp.com,discordapp.net"
      "--dpi-desync=fake"
      "--dpi-desync-fooling=md5sig"
      "--new"

      "--filter-udp=443"
      "--hostlist-domains=discord.com,discord.gg,discordapp.com,discordapp.net"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
      "--new"

      "--filter-tcp=2053,2083,2087,2096,8443"
      "--hostlist-domains=discord.media"
      "--dpi-desync=fake,fakedsplit"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fooling=md5sig"
    ];
  };

  networking.firewall.extraCommands = ''
    ip46tables -t mangle -I POSTROUTING -p tcp -m multiport --dports 2053,2083,2087,2096,8443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass

    # ISP blackholes Cloudflare's 188.114.96.0/20 anycast block and there is no
    # IPv6 uplink to fall back to, so many Cloudflare-hosted sites time out.
    # Redirect the whole block to a reachable edge IP; anycast + SNI routing
    # still serves the correct site regardless of which edge we land on.
    iptables -t nat -A OUTPUT -d 188.114.96.0/20 -p tcp -j DNAT --to-destination 104.16.16.35
  '';
  networking.firewall.extraStopCommands = ''
    ip46tables -t mangle -D POSTROUTING -p tcp -m multiport --dports 2053,2083,2087,2096,8443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass 2>/dev/null || true

    iptables -t nat -D OUTPUT -d 188.114.96.0/20 -p tcp -j DNAT --to-destination 104.16.16.35 2>/dev/null || true
  '';

  # Encrypted DNS (DoT) to prevent ISP DNS hijacking
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "8.8.8.8#dns.google"
      ];
      FallbackDNS = [
        "1.0.0.1"
        "8.8.4.4"
      ];
      Domains = [ "~." ];
      # Roll back to false if DNSSEC causes DNS resolution failures for Discord.
      DNSSEC = "true";
      DNSOverTLS = "true";
    };
  };

  networking.networkmanager.dns = lib.mkForce "systemd-resolved";
}
