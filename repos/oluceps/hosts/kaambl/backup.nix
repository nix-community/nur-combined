{ config, lib, ... }:
{
  services.rustic = {
    profiles = map (n: config.vaultix.secrets.${n}.path) [
      "general.toml"
      "on-kaambl.toml"
      "on-eihort.toml"
    ];
    backups = {
      critic = {
        profiles = map (n: config.vaultix.secrets.${n}.path) [
          "general.toml"
          "on-hastur.toml"
        ];
        timerConfig = {
          OnCalendar = "*-*-1/3 03:00:00";
          RandomizedDelaySec = "4h";
          FixedRandomDelay = true;
          Persistent = true;
        };
      };
    };
  };
}
