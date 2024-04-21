{ pkgs, config, lib, ...}:

lib.mkIf config.services.rtorrent.enable {
  networking.ports = {
    rtorrent-flood.enable = true;
    rtorrent-dht.enable = true;
    rtorrent-port-0000.enable = true;
    rtorrent-port-0001 = {enable = true; port = config.networking.ports.rtorrent-port-0000.port + 1; };
    rtorrent-port-0002 = {enable = true; port = config.networking.ports.rtorrent-port-0001.port + 1; };
    rtorrent-port-0003 = {enable = true; port = config.networking.ports.rtorrent-port-0002.port + 1; };
    rtorrent-port-0004 = {enable = true; port = config.networking.ports.rtorrent-port-0003.port + 1; };
    rtorrent-port-0005 = {enable = true; port = config.networking.ports.rtorrent-port-0004.port + 1; };
    rtorrent-port-0006 = {enable = true; port = config.networking.ports.rtorrent-port-0005.port + 1; };
    rtorrent-port-0007 = {enable = true; port = config.networking.ports.rtorrent-port-0006.port + 1; };
    rtorrent-port-0008 = {enable = true; port = config.networking.ports.rtorrent-port-0007.port + 1; };
    rtorrent-port-0009 = {enable = true; port = config.networking.ports.rtorrent-port-0008.port + 1; };
    rtorrent-port-9999 = {enable = true; port = config.networking.ports.rtorrent-port-0009.port + 1; };
  };
  
  networking.firewall.allowedTCPPortRanges = [{
    from = config.networking.ports.rtorrent-port-0000.port;
    to = config.networking.ports.rtorrent-port-9999.port;
  }];

  services.rtorrent = {
    downloadDir = "${config.services.rtorrent.dataDir}/Downloads";
    openFirewall = true;
    inherit (config.networking.ports.rtorrent-port-0000) port;
    configText = ''
      protocol.pex.set = yes
      trackers.use_udp.set = yes

      dht = on
      dht_port = ${toString config.networking.ports.rtorrent-dht.port}

      pieces.memory.max.set = 768M

      schedule2 = dht_node_1, 5, 0, "dht.add_node=router.utorrent.com:6881"
      schedule2 = dht_node_2, 5, 0, "dht.add_node=dht.transmissionbt.com:6881"
      schedule2 = dht_node_3, 5, 0, "dht.add_node=router.bitcomet.com:6881"
      schedule2 = dht_node_4, 5, 0, "dht.add_node=dht.aelitis.com:6881"

      network.port_range.set = ${toString config.networking.ports.rtorrent-port-0000.port}-${toString config.networking.ports.rtorrent-port-9999.port}

      # dht.add_node = router.bittorrent.com:6881
    '';
  };


  systemd.services.rtorrent = {
    restartIfChanged = true;

    serviceConfig = {
      MemoryHigh = "1G";
      MemoryMax = "2G";
    };
  };

  systemd.services.flood-rtorrent = {
    serviceConfig = {
      User = config.services.rtorrent.user;
      Group = config.services.rtorrent.group;
      ExecStart = "${lib.getExe pkgs.flood} --port ${toString config.networking.ports.rtorrent-flood.port} --auth none --rtsocket ${config.services.rtorrent.rpcSocket}";
      Restart = "on-failure";
    };

    restartIfChanged = true;

    environment = {
      NODE_ENV = "production";
    };

    wantedBy = [ "multi-user.target" ];

    after = [ "rtorrent.service" ];
  };

  services.nginx.virtualHosts."rtorrent.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.networking.ports.rtorrent-flood.port}";
    };
  };
}
