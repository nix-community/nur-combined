{ config, lib, ... }:
{
  repack.bird = {
    enable = true;
    config =
      let
        linkSpec = {
          eihort = ''
          '';
          yidhra = ''
          '';
          abhoth = ''
            limit 10;
          '';
          azasos = ''
          '';
        };

        genLink = host: ''
          interface "wg-${host}" {
            type tunnel;
            hello interval 1s;
            update interval 2s;
            rtt cost 192;
            rtt max 300ms;
            rtt decay 125;
            check link no;
            extended next hop yes;
            ${lib.optionalString (linkSpec ? ${host}) linkSpec.${host}}
          };
        '';
      in
      ''
        protocol babel {
          # interface "wg-kaambl" {
          #   rtt min 10ms;
          #   rtt decay 120;
          # };
        ${lib.concatMapStrings genLink (lib.getPeerHostListFrom config)}
          ipv6 {
            import where in_hortus();
            export filter to_hortus;
          };
        };
      '';
  };
}
