{
  repack.bird = {
    enable = true;
    config = ''
      protocol babel {
        interface "zt*" {
          type wired;
          hello interval 2s;
          update interval 8s;
          rtt cost 192;
          rtt max 300ms;
          rtt decay 60;
          check link no;
          extended next hop yes;
        };
        ipv6 {
          import where in_hortus();
          export filter to_hortus;
        };
      };
    '';
  };
}
