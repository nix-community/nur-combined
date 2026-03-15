{
  config,
  lib,
  ...
}:

let
  cfg = config.repack.plugIn;
  inherit (lib)
    singleton
    ;
  inherit (lib.data) node;
  inherit (config.networking) hostName;
  thisNode = node.${hostName};
in
{
  config = lib.mkIf cfg.enable {

    networking.firewall = {
      trustedInterfaces = [ "zt*" ];
    };

    systemd.network = {
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

    # # https://www.procustodibus.com/blog/2021/11/wireguard-nftables/
    # networking.nftables.ruleset = # nft
    #   ''
    #     table inet filter {
    #       set wg_interfaces {
    #           type ifname
    #           flags dynamic # Allows adding/removing elements from the command line
    #           elements = { ${lib.concatMapStringsSep "," (n: "\"hts-${n}\"") (attrNames thisConn)} }
    #       }
    #     	chain forward {
    #     		type filter hook forward priority filter; policy drop;

    #     		ct state { established, related } accept

    #     		ct state invalid drop

    #     		oifname @wg_interfaces tcp flags syn / syn,rst tcp option maxseg size set rt mtu log prefix "[NFTABLES MSS_CLAMP] " level info

    #     		iifname @wg_interfaces accept
    #     		oifname @wg_interfaces accept
    #     	}
    #     }
    #   '';
    repack.yggdrasil.enable = true;
    services.zerotierone = {
      enable = true;
      joinNetworks = [ "76fc96e49840ce35" ];
    };

  };
}
