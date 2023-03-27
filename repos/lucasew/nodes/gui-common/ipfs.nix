{ config, lib, ... }:
let
  ipfsAPIPort = 65525;
  ipfsSwarmPort = 65526;
in lib.mkIf config.services.kubo.enable {
  services.nginx.virtualHosts."ipfs.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ipfsAPIPort}";
      proxyWebsockets = true;
    };
  };

  services.kubo.autoMount = true;

  services.kubo.settings.Addresses = {
    Swarm = [
      "/ip4/0.0.0.0/tcp/${toString ipfsSwarmPort}"
      "/ip6/::/tcp/${toString ipfsSwarmPort}"
      "/ip4/0.0.0.0/udp/${toString ipfsSwarmPort}/quic"
      "/ip6/::/udp/${toString ipfsSwarmPort}/quic"
    ];
    Gateway = [
      "/ip4/127.0.0.1/tcp/${toString ipfsAPIPort}"
    ];
  };
}
