{ config, ... }:
{
  repack.bird = {
    enable = true;
    config = ''
      # CATCH: repack/bird.nix `if proto = "ext" then accept;`
      protocol direct ext {
        ipv6;
        interface "br0";
      }
      include "${config.vaultix.secrets.babel-auth.path}";
    '';
  };

}
