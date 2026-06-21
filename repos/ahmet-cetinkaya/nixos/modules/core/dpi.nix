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
  '';
  networking.firewall.extraStopCommands = ''
    ip46tables -t mangle -D POSTROUTING -p tcp -m multiport --dports 2053,2083,2087,2096,8443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass 2>/dev/null || true
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
      DNSSEC = "false";
      DNSOverTLS = "true";
    };
  };

  networking.networkmanager.dns = lib.mkForce "systemd-resolved";
}
