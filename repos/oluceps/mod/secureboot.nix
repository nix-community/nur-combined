{ inputs, ... }:
{
  flake.modules.nixos.secureboot =
    { config, ... }:
    {
      imports = [
        inputs.lanzaboote.nixosModules.default
      ];
      boot = {
        bootspec.enable = true;
        lanzaboote = {
          enable = true;
          publicKeyFile = config.vaultix.secrets."db.pem".path;
          privateKeyFile = config.vaultix.secrets."db.key".path;
          configurationLimit = 8;
        };
      };
      vaultix.secrets = {
        "db.key" = { };
        "db.pem" = { };
      };
    };
}
