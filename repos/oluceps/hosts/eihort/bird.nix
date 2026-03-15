{
  repack.bird = {
    enable = true;
    config = ''
      # CATCH: repack/bird.nix `if proto = "ext" then accept;`
      protocol direct ext {
        ipv6;
        ipv4;
        interface "br0";
      }
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
