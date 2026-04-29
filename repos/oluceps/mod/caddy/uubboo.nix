{ self, ... }:
{
  flake.modules.nixos."caddy/uubboo" =
    {
      config,
      ...
    }:
    {
      imports = [ self.modules.nixos.caddy ];
      vaultix.secrets."nyaw.key" = {
        mode = "400";
        owner = config.identity.user;
      };
      vaultix.secrets."nyaw.cert" = {
        mode = "400";
        owner = config.identity.user;
      };
    };
}
