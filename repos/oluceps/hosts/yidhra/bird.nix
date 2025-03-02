{
  repack.bird = {
    enable = true;
    config = ''
      protocol babel {
        interface "wg-*" {
          type tunnel;
          hello interval 1s;
          update interval 2s;
          rtt decay 90;
          check link no;
          extended next hop yes;
        };
        interface "wg-kaambl" {
          rtt min 40ms;
          rtt max 256ms;
          rtt decay 120;
        };
        interface "wg-eihort" {
          rtt min 45ms;
          rtt max 256ms;
        };
        interface "wg-hastur" {
          rtt min 55ms;
          rtt max 256ms;
        };
        interface "wg-abhoth" {
          rtt min 64ms;
          rtt max 256ms;
        };
        interface "wg-azasos" {
          rtt min 40ms;
          rtt max 512ms;
        };
        ipv6 {
          import where in_hortus();
          export filter hortus_export;
        };
      };
    '';
  };

}
