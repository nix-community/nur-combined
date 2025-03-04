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
          yidhra = ''
            rtt min 45ms;
          '';
          abhoth = ''
            rtt min 100ms;
          '';
          kaambl = ''
            rtt min 94ms;
          '';
          hastur = ''
            rtt min 50ms;
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
