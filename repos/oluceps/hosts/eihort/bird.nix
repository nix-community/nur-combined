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
        # interface "wg-kaambl" {
        #   rtt min 20ms;
        #   rtt max 256ms;
        #   rtt decay 32;
        # };
        interface "wg-hastur" {
          rtt min 500us;
          rtt max 4ms;
          rtt decay 52;
        };
        interface "wg-yidhra" {
          rtt min 50ms;
          rtt max 75ms;
        };
        interface "wg-abhoth" {
          rtt min 150ms;
          rtt max 256ms;
        };
        interface "wg-azasos" {
          rtt min 40ms;
          rtt max 80ms;
        };
        ipv6 {
          import where in_hortus();
          export filter hortus_export;
        };
      };
    '';
  };

}
