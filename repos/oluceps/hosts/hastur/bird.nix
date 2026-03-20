{ config, ... }:
{
  repack.bird = {
    enable = true;
    config = ''
      protocol bgp k8s_net {
        local as 64512;
        neighbor fdcc:1::2 as 64512; # vm ipv6 address
        ipv6 {
          import all; # accept vip from vm
          export none;
        };
      };
      # CATCH: repack/bird.nix `if proto = "ext" then accept;`
      protocol direct ext {
        ipv6;
        interface "br0";
      };
      include "${config.vaultix.secrets.babel-auth.path}";
    '';
  };
}
