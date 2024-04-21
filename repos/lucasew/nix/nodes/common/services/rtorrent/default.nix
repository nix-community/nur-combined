{ pkgs, config, lib, ...}:

lib.mkIf config.services.rtorrent.enable {
  services.rtorrent = {
    downloadDir = "${config.services.rtorrent.dataDir}/Downloads";
    openFirewall = true;
  };

  networking.ports.flood-rtorrent.enable = true;

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
