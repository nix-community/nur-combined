{ config, lib, ... }:
{
  repack.bird = {
    enable = true;
    config =
      let
        linkSpec = {
          eihort = ''
            rtt min 4ms;
          '';
          yidhra = ''
            rtt min 60ms;
          '';
          abhoth = ''
            rtt min 160ms;
            rtt decay 128;
            limit 10;
          '';
          azasos = ''
            rtt min 60ms;
          '';
          # kaambl = ''
          #   rtt min 10ms;
          #   rtt decay 120;
          # '';
        };

        genLink = host: ''
          interface "wg-${host}" {
            type tunnel;
            hello interval 1s;
            update interval 2s;
            rtt cost 192;
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
