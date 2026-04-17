{ self, ... }:
{
  flake.modules.nixos."bird/yidhra" =
    { config, ... }:
    {
      imports = [ self.modules.nixos.bird ];
      vaultix.secrets.babel-auth = {
        owner = "bird";
      };
      bird = {
        config = ''
          include "${config.vaultix.secrets.babel-auth.path}";
        '';
      };
    };
}
