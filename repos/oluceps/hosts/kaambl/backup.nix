{ config, lib, ... }:
{
  services.rustic = {
    profiles = map (n: config.vaultix.secrets.${n}.path) [
      "general.toml"
      "on-kaambl.toml"
      "on-eihort.toml"
    ];
    backups = {

    };
  };
}
