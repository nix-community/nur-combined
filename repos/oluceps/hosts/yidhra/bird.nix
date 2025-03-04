{ config, lib, ... }:
{
  repack.bird = {
    enable = true;
    config =
      let
        linkSpec = {
          eihort = ''
            rtt min 45ms;
          '';
          azasos = ''
            rtt min 40ms;
          '';
          abhoth = ''
            rtt min 64ms;
          '';
          kaambl = ''
            rtt min 40ms;
            rtt decay 120;
          '';
          hastur = ''
            rtt min 55ms;
          '';
        };

        genLink = host: ''
          interface "wg-${host}" {
            type tunnel;
            hello interval 1s;
            update interval 2s;
            rtt cost 96;
            rtt max 180ms;
            rtt decay 64;
            check link no;
            extended next hop yes;
            ${lib.optionalString (linkSpec ? ${host}) linkSpec.${host}}
          };
        '';
      in
      ''
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
