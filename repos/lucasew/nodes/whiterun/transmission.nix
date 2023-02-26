{ config, ... }: {
  systemd.services.transmission.serviceConfig.BindPaths = [
    "/storage/downloads"
  ];
  services.transmission = {
    enable = true;
    openFirewall = true;
    openPeerPorts = true;
    settings = {
      peer-port-random-on-start = true;
      peer-port-random-low = 65510;
      peer-port-random-high = 65535;
      message-level = 3; # journalctl all the things, hope it doesnt spam
      utp-enabled = true;
    };
  };
  services.nginx.virtualHosts."transmission.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
    };
  };
}
