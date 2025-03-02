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
        # interface "wg-hastur" {
        #   rtt min 10ms;
        #   rtt max 256ms;
        #   rtt decay 90;
        # };
        # interface "wg-eihort" {
        #   rtt min 5ms;
        #   rtt max 256ms;
        #   rtt decay 90;
        # };
        interface "wg-yidhra" {
          rtt min 38ms;
          rtt max 256ms;
        };
        interface "wg-abhoth" {
          rtt min 77ms;
          rtt max 256ms;
        };
        interface "wg-azasos" {
          rtt min 33ms;
          rtt max 256ms;
        };
        ipv6 {
          import where in_hortus();
          export filter to_hortus;
        };
      };
    '';
  };

}
