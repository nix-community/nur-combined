{ config, lib, ... }:
{
  repack.bird = {
    enable = true;
    config =
      let
        linkSpec = {
          eihort = ''
          '';
          azasos = ''
          '';
          abhoth = ''
          '';
          kaambl = ''
          '';
          hastur = ''
          '';
        };

        genLink = host: ''
          interface "hts-${host}" {
            type tunnel;
            hello interval 1s;
            update interval 2s;
            rtt cost 192;
            rtt max 300ms;
            rtt decay 60;
            check link no;
            extended next hop yes;
            ${lib.optionalString (linkSpec ? ${host}) linkSpec.${host}}
          };
        '';
      in
      ''
        protocol static {
          ipv6;
          route ::/0 via fdcc::5;
        }
        protocol babel {
        ${lib.concatMapStrings genLink (lib.getPeerHostListFrom config)}
         ipv6 {
            import where in_hortus();
            export filter to_hortus;
          };
        };
      '';
  };

}
