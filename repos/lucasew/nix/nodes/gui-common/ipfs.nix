{ config, lib, ... }:

lib.mkIf config.services.kubo.enable {
  networking.ports.ipfs-gateway.enable = true;
  # networking.ports.ipfs-gateway.port = lib.mkDefault 49148;
  networking.ports.ipfs-api.enable = true;
  # networking.ports.ipfs-api.port = lib.mkDefault 49142;
  networking.ports.ipfs-swarm.enable = true;
  # networking.ports.ipfs-swarm.port = lib.mkDefault 49141;

  services.nginx.virtualHosts."ipfs.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.networking.ports.ipfs-api.port}";
      proxyWebsockets = true;
    };
  };

  services.kubo.autoMount = true;

  services.kubo.settings.Addresses = {
    Swarm = [
      "/ip4/0.0.0.0/tcp/${toString config.networking.ports.ipfs-swarm.port}"
      "/ip6/::/tcp/${toString config.networking.ports.ipfs-swarm.port}"
      "/ip4/0.0.0.0/udp/${toString config.networking.ports.ipfs-swarm.port}/quic"
      "/ip6/::/udp/${toString config.networking.ports.ipfs-swarm.port}/quic"
    ];
    Gateway = "/ip4/127.0.0.1/tcp/${toString config.networking.ports.ipfs-gateway.port}";
    API = "/ip4/127.0.0.1/tcp/${toString config.networking.ports.ipfs-api.port}";
  };
}
