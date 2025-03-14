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
          interface "wg-${host}" {
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
