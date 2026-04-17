{
  flake.modules.nixos.sing-server =
    { config, ... }:
    {
      vaultix.secrets.sing-server = {
        owner = "sing-server";
        mode = "400";
      };
      services.sing-server.enable = true;
    };
}
