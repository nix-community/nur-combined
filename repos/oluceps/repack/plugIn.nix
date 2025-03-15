{
  config,
  lib,
  ...
}:

let
  cfg = config.repack.plugIn;

  inherit (builtins)
    attrNames
    attrValues
    ;
  inherit (lib)
    recursiveUpdate
    optionalAttrs
    singleton
    mapAttrsToList
    foldr
    ;
  inherit (lib.data) node;
  inherit (config.networking) hostName;
  thisConn = (lib.conn { }).${hostName};
  allowedUDPPorts = attrValues thisConn;
  trustedInterfaces = map (n: "hts-" + n) (attrNames thisConn);
  thisNode = node.${hostName};

  ifNeed =
    peerNode: prod:
    optionalAttrs (
      !(thisNode.nat && peerNode.nat && thisNode ? loc && peerNode ? loc && thisNode.loc != peerNode.loc)
    ) prod;

  genPeer =
    peerName: port:
    let
      peerNode = node.${peerName};
      directConnect = ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));
    in
    ifNeed peerNode {
      networks."10-wireguard-hts-${peerName}" = {
        matchConfig.Name = "hts-${peerName}";
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
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };
      netdevs."10-hts-${peerName}" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "hts-${peerName}";
          MTUBytes = if directConnect then 1420 else 1380;
        };
        wireguardConfig =
          {
            PrivateKeyFile = config.vaultix.secrets."wg-${hostName}".path;
            RouteTable = false;
          }
          // (optionalAttrs ((thisNode.nat -> peerNode.nat) && (thisNode.censor -> peerNode.censor)) {
            ListenPort = port;
          });
        wireguardPeers = singleton (
          {
            PublicKey = peerNode.pub_key;
            AllowedIPs = [
              "::/0"
              "0.0.0.0/0"
            ];
            PresharedKeyFile = config.vaultix.secrets.psk.path;
            RouteTable = false;
          }
          // optionalAttrs (thisNode.nat || !peerNode.nat) {
            Endpoint =
              let
                port = toString thisConn.${peerName};
                addr = if directConnect then peerNode.addr else "127.0.0.1";
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

    networking.firewall = { inherit allowedUDPPorts trustedInterfaces; };

    systemd.network = recursiveUpdate (foldr recursiveUpdate { } (mapAttrsToList genPeer thisConn)) {
      netdevs."10-anchor-0" = {
        enable = true;
        netdevConfig = {
          Kind = "dummy";
          Name = "anchor-0";
        };
      };
      networks."10-dummy-anchor-0" = {
        enable = true;
        DHCP = "no";
        matchConfig.Name = "anchor-0";
        address = singleton thisNode.unique_addr;
      };
    };
  };
}
