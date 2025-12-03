{ config, ... }:
{
  services.monero = {
    enable = true;
    rpc.restricted = true;
    rpc.address = "10.78.79.22";
    limits.upload = 50 * 1000;
    limits.download = 500 * 1000;
    limits.threads = 4;
    # todo once initial sync finishes: db-sync-mode=safe:sync
    extraConfig = ''
      no-igd=1
      enforce-dns-checkpointing=1
      p2p-bind-ip=${config.vacu.hosts.prophecy.primaryIp}
      out-peers=100
      in-peers=100
      confirm-external-bind=1
      no-zmq=1
    '';
    dataDir = "/propdata/chains/monero";
  };

  networking.firewall.allowedTCPPorts = [
    18080
    18081
  ];
}
