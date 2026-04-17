{ self, ... }:
{
  flake.modules.nixos."bird/eihort" =
    { config, ... }:
    {
      imports = [ self.modules.nixos.bird ];
      vaultix.secrets.babel-auth = {
        owner = "bird";
      };
      bird = {
        config = ''
          # CATCH: repack/bird.nix `if proto = "ext" then accept;`
          protocol direct ext {
            ipv6;
            interface "br0";
          };
          include "${config.vaultix.secrets.babel-auth.path}";
        '';
      };
    };
}
