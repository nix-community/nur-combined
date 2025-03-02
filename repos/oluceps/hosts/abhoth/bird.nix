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
          rtt min 75ms;
          rtt max 512ms;
          rtt decay 120;
        };
        interface "wg-eihort" {
          rtt min 170ms;
          rtt max 380ms;
        };
        interface "wg-hastur" {
          rtt min 160ms;
          rtt max 256ms;
        };
        interface "wg-yidhra" {
          rtt min 64ms;
          rtt max 256ms;
        };
        interface "wg-azasos" {
          rtt min 50ms;
          rtt max 256ms;
        };
        ipv6 {
          import where in_hortus();
          export filter hortus_export;
        };
      };
    '';
  };

}
