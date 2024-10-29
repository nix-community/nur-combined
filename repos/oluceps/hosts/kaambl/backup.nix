{ config, lib, ... }:
{
  services.rustic = {
    profiles = map (n: config.age.secrets.${n}.path) [
      "general.toml"
      "on-kaambl.toml"
      "on-eihort.toml"
    ];
    backups = {

    };
  };
}
