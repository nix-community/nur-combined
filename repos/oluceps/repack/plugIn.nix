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
    elemAt
    ;
  inherit (lib.data) node;
  inherit (config.networking) hostName;
  thisConn = (lib.conn { }).${hostName};
  allowedUDPPorts = attrValues thisConn;
  trustedInterfaces = map (n: "hts-" + n) (attrNames thisConn);
  thisNode = node.${hostName};

  ifAble2Connect =
    peerNode: prod:
    optionalAttrs (
      !(
        thisNode.nat
        && peerNode.nat
        && thisNode ? region
        && peerNode ? region
        && thisNode.region != peerNode.region
      )
    ) prod;

  genPeer =
    peerName: port:
    let
      peerNode = node.${peerName};
      directConnect = ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));
    in
    ifAble2Connect peerNode {
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
        networkConfig = {
          IPMasquerade = "ipv6";
          IPv6Forwarding = true;
        };
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };
      netdevs."10-hts-${peerName}" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "hts-${peerName}";
          MTUBytes = if directConnect then 1400 else 1350; # 1500 - quic 38bytes - hy2 24bytes - wg 32bytes
        };
        wireguardConfig = {
          PrivateKeyFile = config.vaultix.secrets."wg-${hostName}".path;
          RouteTable = false;
        }
        // (optionalAttrs ((thisNode.nat -> peerNode.nat) && (thisNode.censor -> peerNode.censor)) {
          ListenPort = port;
        });
        wireguardPeers = singleton (
          {
            PublicKey = peerNode.wg_key;
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
                addr =
                  if directConnect then
                    if peerNode ? addrs then (elemAt peerNode.addrs 0) else (elemAt peerNode.identifiers 0).name
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

    networking.firewall = { inherit allowedUDPPorts trustedInterfaces; };

    boot.kernel.sysctl = lib.foldr (
      i: acc:
      acc
      // {
        "net.ipv4.conf.hts-${i}.rp_filter" = 0;
        "net.ipv6.conf.hts-${i}.rp_filter" = 0;
      }
    ) { } (builtins.attrNames thisConn);

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

    # https://www.procustodibus.com/blog/2021/11/wireguard-nftables/
    networking.nftables.ruleset = # nft
      ''
        table inet filter {
          set wg_interfaces {
              type ifname
              flags dynamic # Allows adding/removing elements from the command line
              elements = { ${lib.concatMapStringsSep "," (n: "\"hts-${n}\"") (attrNames thisConn)} }
          }
        	chain forward {
        		type filter hook forward priority filter; policy drop;

        		ct state { established, related } accept

        		ct state invalid drop

        		oifname @wg_interfaces tcp flags syn / syn,rst tcp option maxseg size set rt mtu log prefix "[NFTABLES MSS_CLAMP] " level info

        		iifname @wg_interfaces accept
        		oifname @wg_interfaces accept
        	}
        }
      '';
  };
}
