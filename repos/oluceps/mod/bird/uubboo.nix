{ self, ... }:
{
  flake.modules.nixos."bird/uubboo" =
    { config, ... }:
    {
      imports = [ self.modules.nixos.bird ];
      vaultix.secrets.babel-auth = {
        owner = "bird";
      };
      bird = {
        config = ''
          protocol direct ext {
            ipv6;
            interface "eno1";
          };
          include "${config.vaultix.secrets.babel-auth.path}";
        '';
      };
    };
}
