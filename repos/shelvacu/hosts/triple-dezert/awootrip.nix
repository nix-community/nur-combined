let
  prefix = "10.16.237.";
  tripAddr = prefix + "2";
  awooAddr = prefix + "1";
  devName = "at4"; # It was my fourth attempt before it worked...
  tunnelName = "awootrip";
in
{
  systemd.network.netdevs.${devName} = {
    netdevConfig = {
      Kind = "tun";
      Name = devName;
    };
    enable = true;
  };

  systemd.network.networks."05-${tunnelName}net".extraConfig = ''
    [Match]
    Name = ${devName}

    [Link]
    Unmanaged = no

    [Network]
    LinkLocalAddressing = no
    ConfigureWithoutCarrier = yes

    [Address]
    Address = ${tripAddr}/32
    Peer = ${awooAddr}
    Scope = link

    [Route]
    Gateway=${awooAddr}
    Table=${tunnelName}

    [RoutingPolicyRule]
    From=${tripAddr}
    Table=${tunnelName}
  '';

  networking.firewall.extraCommands = ''
    if ! (iptables -t mangle -n --list ${tunnelName}-prerouting > /dev/null 2>&1); then
      iptables -t mangle -N ${tunnelName}-prerouting
    fi
    iptables -t mangle -I nixos-fw-rpfilter 1 -j ${tunnelName}-prerouting
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t mangle -D nixos-fw-rpfilter -j ${tunnelName}-prerouting || true
  '';

  systemd.network.config.routeTables.${tunnelName} = 421;
  systemd.network.config.addRouteTablesToIPRoute2 = true;

  services.openvpn.servers.${tunnelName} = {
    config = ''
      remote 45.142.157.71
      # HACK this relies on the static ip being assigned by the router
      # local 10.78.79.237
      nobind
      dev ${devName}
      dev-type tun
      ifconfig ${tripAddr} ${awooAddr}
      secret /root/awootrip/awootrip.key
      cipher AES-256-CBC

      keepalive 1 5
      ping-timer-rem
      persist-tun
      persist-key
      tun-mtu 1400
      fragment 1300
      mssfix

      verb 4
    '';
    up = ''
      iptables -t mangle -F ${tunnelName}-prerouting
      iptables -t mangle -A ${tunnelName}-prerouting -i ${devName} -j RETURN
    '';
    down = ''
      iptables -t mangle -F ${tunnelName}-prerouting
    '';
    autoStart = true;
  };
}
