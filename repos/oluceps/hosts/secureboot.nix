{ config, ... }:
{
  boot = {
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      publicKeyFile = config.vaultix.secrets."db.pem".path;
      privateKeyFile = config.vaultix.secrets."db.key".path;
    };
  };
}
