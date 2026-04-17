{
  flake.modules.nixos.plugIn =
    {
      ...
    }:
    {

      networking.firewall = {
        trustedInterfaces = [
          "xfrm-*"
          "hts-0"
        ];
      };

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
    };
}
