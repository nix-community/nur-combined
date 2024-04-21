{ pkgs, config, lib, ...}:

lib.mkIf config.services.rtorrent.enable {
  networking.ports.flood-rtorrent.enable = true;
  networking.ports.rtorrent.enable = true;
  networking.ports.rtorrent-dht.enable = true;

  services.rtorrent = {
    downloadDir = "${config.services.rtorrent.dataDir}/Downloads";
    openFirewall = true;
    inherit (config.networking.ports.rtorrent) port;
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
      ExecStart = "${lib.getExe pkgs.flood} --port ${toString config.networking.ports.flood-rtorrent.port} --auth none --rtsocket ${config.services.rtorrent.rpcSocket}";
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
      proxyPass = "http://127.0.0.1:${toString config.networking.ports.flood-rtorrent.port}";
    };
  };
}
