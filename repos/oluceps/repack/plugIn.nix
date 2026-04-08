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
      trustedInterfaces = [
        "xfrm-*"
        "hts-0"
      ];
    };

    # systemd.network = {
    # netdevs."10-anchor-0" = {
    #   enable = true;
    #   netdevConfig = {
    #     Kind = "dummy";
    #     Name = "anchor-0";
    #   };
    # };
    # networks."10-dummy-anchor-0" = {
    #   enable = true;
    #   DHCP = "no";
    #   matchConfig.Name = "anchor-0";
    #   address = singleton thisNode.unique_addr;
    # };
    # };

    # # https://www.procustodibus.com/blog/2021/11/wireguard-nftables/
    networking.nftables.tables.filter = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority filter; policy accept;
          
          oifname "hts-0" tcp flags & (syn | rst) == syn tcp option maxseg size set rt mtu
          iifname "hts-0" tcp flags & (syn | rst) == syn tcp option maxseg size set rt mtu
        }
      '';
    };
    repack.yggdrasil.enable = true;
    # repack.wg-partial-mesh.enable = true;
    # services.zerotierone = {
    #   enable = true;
    #   joinNetworks = [ "76fc96e49840ce35" ];
    # };
    # repack.ranet.enable = true;
    repack.vxlan-mesh.enable = true;

  };
}
