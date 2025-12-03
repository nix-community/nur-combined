{
  config,
  lib,
  pkgs,
  ...
}:
let
  dataDir = "/propdata/chains/ethereum";
  port = 30303;
in
{
  # services.geth.main = {
  #   enable = true;
  #   syncmode = "full";
  #   gcmode = "archive";
  #   websocket.enable = false;
  #   metrics.enable = false;
  #   http.enable = false;
  #   authrpc.enable = false;
  #   # extraArgs = [ "--nows" ];
  # };

  users.users.ethereum-node = {
    isSystemUser = true;
    group = "ethereum-node";
  };

  users.groups.ethereum-node = { };

  # services.erigon = {
  #   enable = true;
  # };

  # systemd.services.geth-node = {
  #   description = "Go Ethereum node";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #
  #   serviceConfig = {
  #     DynamicUser = lib.mkForce false;
  #     User = "geth-node";
  #     Group = "geth-node";
  #     Restart = "always";
  #
  #     PrivateTmp = true;
  #     ProtectSystem = "full";
  #     NoNewPrivileges = true;
  #     PrivateDevices = true;
  #     MemoryDenyWriteExecute = true;
  #
  #     BindPaths = [ dataDir ];
  #   };
  #
  #   # https://geth.ethereum.org/docs/fundamentals/command-line-options
  #   script = ''
  #     declare -a args=(
  #       ${pkgs.go-ethereum}/bin/geth
  #       --ipcdisable
  #       --syncmode full
  #       --gcmode archive
  #       --port ${toString port}
  #       --maxpeers 100
  #       --datadir ${lib.escapeShellArg dataDir}
  #       --mainnet
  #       --nat extip:${config.vacu.hosts.prophecy.primaryIp}
  #     )
  #     "''${args[@]}"
  #   '';
  # };
  #
  # services.lighthouse = {
  #   beacon = {
  #     enable = true;
  #     address = config.vacu.hosts.prophecy.primaryIp;
  #     openFirewall = true;
  #     metrics.enable = false;
  #     http.enable = false;
  #     dataDir = "${dataDir}/lighthouse-beacon";
  #   };
  # };

  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };
}
