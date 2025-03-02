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
  inherit (lib) concatMapAttrs optionalAttrs singleton;
  inherit (lib.data) node;
  inherit (config.networking) hostName;
  thisConn = (lib.conn { }).${hostName};
  allowedUDPPorts = attrValues thisConn;
  trustedInterfaces = map (n: "wg-" + n) (attrNames thisConn);
  thisNode = node.${hostName};

  ifNeed =
    peerNode: prod:
    optionalAttrs (
      !(thisNode.nat && peerNode.nat && thisNode ? loc && peerNode ? loc && thisNode.loc != peerNode.loc)
    ) prod;

  genPeerNetwork =
    peerName: port:
    let
      peerNode = node.${peerName};
    in
    ifNeed peerNode {
      "10-wg-${peerName}" = {
        matchConfig.Name = "wg-${peerName}";
        addresses = [
          {
            Address = thisNode.unique_addr;
          }
          {
            Address = thisNode.link_local_addr;
            Scope = "link";
          }
        ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };
    };
  genPeerNetdev =
    peerName: port:
    let
      peerNode = node.${peerName};
      directConnect = ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));
    in
    ifNeed peerNode {
      "wg-${peerName}" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg-${peerName}";
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

    boot.kernel.sysctl = lib.foldr (
      i: acc:
      acc
      // {
        "net.ipv4.conf.wg-${i}.rp_filter" = 0;
        "net.ipv6.conf.wg-${i}.rp_filter" = 0;
      }
    ) { } (builtins.attrNames thisConn);

    # it dont recursiveUpdate :\
    systemd.network.netdevs = (concatMapAttrs genPeerNetdev thisConn) // {
      "anchor-0" = {
        enable = true;
        netdevConfig = {
          Kind = "dummy";
          Name = "anchor-0";
        };
      };
    };
    systemd.network.networks = (concatMapAttrs genPeerNetwork thisConn) // {
      anchor-0 = {
        enable = true;
        DHCP = "no";
        name = "anchor-0";
        matchConfig = {
          Name = "anchor-0";
        };
        address = singleton thisNode.unique_addr;
      };
    };
  };
}
