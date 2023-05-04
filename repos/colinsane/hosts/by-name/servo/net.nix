{ config, pkgs, ... }:

{
  networking.domain = "uninsane.org";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  # XXX colin: probably don't need this. wlan0 won't be populated unless i touch a value in networking.interfaces.wlan0
  networking.wireless.enable = false;

  # networking.firewall.enable = false;
  networking.firewall.enable = true;

  # this is needed to forward packets from the VPN to the host
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # unless we add interface-specific settings for each VPN, we have to define nameservers globally.
  # networking.nameservers = [
  #   "1.1.1.1"
  #   "9.9.9.9"
  # ];

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

  # services.resolved.extraConfig = ''
  #   # docs: `man resolved.conf`
  #   # DNS servers to use via the `wg-ovpns` interface.
  #   #   i hope that from the root ns, these aren't visible.
  #   DNS=46.227.67.134%wg-ovpns 192.165.9.158%wg-ovpns
  #   FallbackDNS=1.1.1.1 9.9.9.9
  # '';

  # OVPN CONFIG (https://www.ovpn.com):
  # DOCS: https://nixos.wiki/wiki/WireGuard
  # if you `systemctl restart wireguard-wg-ovpns`, make sure to also restart any other services in `NetworkNamespacePath = .../ovpns`.
  # TODO: why not create the namespace as a seperate operation (nix config for that?)
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg-ovpns = let
    ip = "${pkgs.iproute2}/bin/ip";
    in-ns = "${ip} netns exec ovpns";
    iptables = "${pkgs.iptables}/bin/iptables";
    veth-host-ip = "10.0.1.5";
    veth-local-ip = "10.0.1.6";
    vpn-ip = "185.157.162.178";
    # DNS = 46.227.67.134, 192.165.9.158, 2a07:a880:4601:10f0:cd45::1, 2001:67c:750:1:cafe:cd45::1
    vpn-dns = "46.227.67.134";
  in {
    privateKeyFile = config.sops.secrets.wg_ovpns_privkey.path;
    # wg is active only in this namespace.
    # run e.g. ip netns exec ovpns <some command like ping/curl/etc, it'll go through wg>
    #   sudo ip netns exec ovpns ping www.google.com
    interfaceNamespace = "ovpns";
    ips = [
      "185.157.162.178/32"
    ];
    peers = [
      {
        publicKey = "SkkEZDCBde22KTs/Hc7FWvDBfdOCQA4YtBEuC3n5KGs=";
        endpoint = "185.157.162.10:9930";
        # alternatively: use hostname, but that presents bootstrapping issues (e.g. if host net flakes)
        # endpoint = "vpn36.prd.amsterdam.ovpn.com:9930";
        allowedIPs = [ "0.0.0.0/0" ];
        # nixOS says this is important for keeping NATs active
        persistentKeepalive = 25;
        # re-executes wg this often. docs hint that this might help wg notice DNS/hostname changes.
        # so, maybe that helps if we specify endpoint as a domain name
        # dynamicEndpointRefreshSeconds = 30;
        # when refresh fails, try it again after this period instead.
        # TODO: not avail until nixpkgs upgrade
        # dynamicEndpointRefreshRestartSeconds = 5;
      }
    ];
    preSetup = "" + ''
      ${ip} netns add ovpns || echo "ovpns already exists"
    '';
    postShutdown = "" + ''
      ${in-ns} ip link del ovpns-veth-b || echo "couldn't delete ovpns-veth-b"
      ${ip} link del ovpns-veth-a || echo "couldn't delete ovpns-veth-a"
      ${ip} netns delete ovpns || echo "couldn't delete ovpns"
      # restore rules/routes
      ${ip} rule del from ${veth-host-ip} lookup ovpns pref 50 || echo "couldn't delete init -> ovpns rule"
      ${ip} route del default via ${veth-local-ip} dev ovpns-veth-a proto kernel src ${veth-host-ip} metric 1002 table ovpns || echo "couldn't delete init -> ovpns route"
      ${ip} rule add from all lookup local pref 0
      ${ip} rule del from all lookup local pref 100
    '';
    postSetup = "" + ''
      # DOCS:
      # - some of this approach is described here: <https://josephmuia.ca/2018-05-16-net-namespaces-veth-nat/>
      # - iptables primer: <https://danielmiessler.com/study/iptables/>
      # create veth pair
      ${ip} link add ovpns-veth-a type veth peer name ovpns-veth-b
      ${ip} addr add ${veth-host-ip}/24 dev ovpns-veth-a
      ${ip} link set ovpns-veth-a up

      # mv veth-b into the ovpns namespace
      ${ip} link set ovpns-veth-b netns ovpns
      ${in-ns} ip addr add ${veth-local-ip}/24 dev ovpns-veth-b
      ${in-ns} ip link set ovpns-veth-b up

      # make it so traffic originating from the host side of the veth
      # is sent over the veth no matter its destination.
      ${ip} rule add from ${veth-host-ip} lookup ovpns pref 50
      # for traffic originating at the host veth to the WAN, use the veth as our gateway
      # not sure if the metric 1002 matters.
      ${ip} route add default via ${veth-local-ip} dev ovpns-veth-a proto kernel src ${veth-host-ip} metric 1002 table ovpns
      # give the default route lower priority
      ${ip} rule add from all lookup local pref 100
      ${ip} rule del from all lookup local pref 0

      # bridge HTTP traffic:
      # any external port-80 request sent to the VPN addr will be forwarded to the rootns.
      # this exists so LetsEncrypt can procure a cert for the MX over http.
      # TODO: we could use _acme_challence.mx.uninsane.org CNAME to avoid this forwarding
      # - <https://community.letsencrypt.org/t/where-does-letsencrypt-resolve-dns-from/37607/8>
      ${in-ns} ${iptables} -A PREROUTING -t nat -p tcp --dport 80 -m iprange --dst-range ${vpn-ip} \
        -j DNAT --to-destination ${veth-host-ip}:80

      # we also bridge DNS traffic
      ${in-ns} ${iptables} -A PREROUTING -t nat -p udp --dport 53 -m iprange --dst-range ${vpn-ip} \
        -j DNAT --to-destination ${veth-host-ip}:53
      ${in-ns} ${iptables} -A PREROUTING -t nat -p tcp --dport 53 -m iprange --dst-range ${vpn-ip} \
        -j DNAT --to-destination ${veth-host-ip}:53

      # in order to access DNS in this netns, we need to route it to the VPN's nameservers
      # - alternatively, we could fix DNS servers like 1.1.1.1.
      ${in-ns} ${iptables} -A OUTPUT -t nat -p udp --dport 53 -m iprange --dst-range 127.0.0.53 \
        -j DNAT --to-destination ${vpn-dns}:53
    '';
  };

  # create a new routing table that we can use to proxy traffic out of the root namespace
  # through the ovpns namespace, and to the WAN via VPN.
  networking.iproute2.rttablesExtraConfig = ''
    5 ovpns
  '';
  networking.iproute2.enable = true;


  # HURRICANE ELECTRIC CONFIG:
  # networking.sits = {
  #   hurricane = {
  #     remote = "216.218.226.238";
  #     local = "192.168.0.5";
  #     # local = "10.0.0.5";
  #     # remote = "10.0.0.1";
  #     # local = "10.0.0.22";
  #     dev = "eth0";
  #     ttl = 255;
  #   };
  # };
  # networking.interfaces."hurricane".ipv6 = {
  #   addresses = [
  #     # mx.uninsane.org (publically routed /64)
  #     {
  #       address = "2001:470:b:465::1";
  #       prefixLength = 128;
  #     }
  #     # client addr
  #     # {
  #     #   address = "2001:470:a:466::2";
  #     #   prefixLength = 64;
  #     # }
  #   ];
  #   routes = [
  #     {
  #       address = "::";
  #       prefixLength = 0;
  #       # via = "2001:470:a:466::1";
  #     }
  #   ];
  # };

  # # after configuration, we want the hurricane device to look like this:
  # # hurricane: flags=209<UP,POINTOPOINT,RUNNING,NOARP>  mtu 1480
  # #            inet6 2001:470:a:450::2  prefixlen 64  scopeid 0x0<global>
  # #            inet6 fe80::c0a8:16  prefixlen 64  scopeid 0x20<link>
  # #            sit  txqueuelen 1000  (IPv6-in-IPv4)
  # # test with:
  # #   curl --interface hurricane http://[2607:f8b0:400a:80b::2004]
  # #   ping 2607:f8b0:400a:80b::2004
}
