{ config, ... }:
{
  services.bitcoind.main = {
    enable = true;
    extraConfig = ''
      bind=${config.vacu.hosts.prophecy.primaryIp}
      blocksdir=/propdata/chains/bitcoin
      txindex=1
      disablewallet=1
      rpcallowip=10.78.76.0/22
      rpcbind=10.78.79.22:8332
      rest=1
    '';
  };

  networking.firewall.allowedTCPPorts = [
    8332
    8333
  ];
}
