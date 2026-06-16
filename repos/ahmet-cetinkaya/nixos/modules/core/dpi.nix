{
  lib,
  pkgs,
  ...
}: {
  services.zapret = {
    enable = true;

    # Route UDP to the queue for QUIC and Discord voice
    udpSupport = true;
    udpPorts = [
      "443"
      "19294:19344"
      "50000:50100"
    ];

    params = [
      # TCP 443: Discord web, API, CDN (working strategy for Türksat Kablonet)
      "--filter-tcp=443"
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-split-pos=1"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fooling=md5sig"
      "--new"

      # UDP/443: QUIC (Discord web, HTTP/3)
      "--filter-udp=443"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fake-quic=${pkgs.zapret}/usr/share/zapret/files/fake/quic_initial_www_google_com.bin"
      "--new"

      # UDP voice/RTC: Discord voice channels and STUN
      "--filter-udp=19294-19344,50000-50100"
      "--filter-l7=discord,stun"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fake-discord=${pkgs.zapret}/usr/share/zapret/files/fake/discord-ip-discovery-without-port.bin"
      "--new"

      # TCP alternate ports: Discord CDN and media delivery
      "--filter-tcp=2053,2083,2087,2096,8443"
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-split-pos=1"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fooling=md5sig"

      # Exclude local network traffic
      "--ipset-exclude-ip=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.0/8,169.254.0.0/16"
    ];
  };

  # Route Discord alternate TCP ports into the nfqueue (module only handles 80/443 by default)
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

  # Zapret is transparent — no system-wide proxy variables needed.
  networking = {
    proxy = {
      default = null;
      httpProxy = null;
      httpsProxy = null;
    };

    # Force public DNS to avoid hijacking
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    resolvconf.extraConfig = ''
      name_servers="1.1.1.1 8.8.8.8"
    '';
    networkmanager.dns = lib.mkForce "none";
  };
}
