{
  config,
  lib,
  ...
}:

let
  cfg = config.repack.plugIn;

  inherit (builtins) readFile fromTOML attrValues;
  inherit (lib) concatMapAttrs optionalAttrs singleton;
  inherit (fromTOML (readFile ../hosts/sum.toml)) node;
  inherit (config.networking) hostName;
  allConn = (lib.conn { }).${hostName};

  allowedUDPPorts = attrValues allConn;

  genPeerNetwork =
    peerName: port:
    let
      peerNode = node.${peerName};
      thisNode = node.${hostName};
    in
    {
      "10-wg-${peerName}" = {
        matchConfig.Name = "wg-${peerName}";
        addresses = [
          {
            Address = thisNode.unique_addr;
            Peer = peerNode.unique_addr;
          }
          {
            Address = thisNode.link_local_addr;
            Peer = peerNode.link_local_addr;
            Scope = "link";
          }
        ];
        networkConfig = {
          DHCP = false;
        };
      };
    };
  genPeerNetdev =
    peerName: port:
    let
      peerNode = node.${peerName};
      thisNode = node.${hostName};
    in
    {
      "wg-${peerName}" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg-${peerName}";
          MTUBytes = "1300";
        };
        wireguardConfig =
          {
            PrivateKeyFile = config.vaultix.secrets."wg-${hostName}".path;
            RouteTable = false;
          }
          // (optionalAttrs (thisNode.nat -> peerNode.nat) {
            ListenPort = port;
          });
        wireguardPeers = singleton (
          {
            PublicKey = peerNode.pub_key;
            AllowedIPs = [
              "::/0"
              "0.0.0.0/0"
            ];

            RouteTable = false;
          }
          // optionalAttrs (thisNode.nat || !peerNode.nat) {
            Endpoint =
              let
                port = toString allConn.${peerName};
                addr =
                  if ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor)) then
                    peerNode.addr
                  else
                    "127.0.0.1";
              in
              (addr + ":" + port);
          }
          // optionalAttrs thisNode.censor {
            PersistentKeepalive = 15;
          }
        );
      };
    };

in
{
  config = lib.mkIf cfg.enable {

    networking.firewall = { inherit allowedUDPPorts; };

    # it dont recursiveUpdate :\
    systemd.network.netdevs = concatMapAttrs genPeerNetdev allConn;
    systemd.network.networks = concatMapAttrs genPeerNetwork allConn;
  };
}
