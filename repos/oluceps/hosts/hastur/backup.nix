{ config, lib, ... }:
{
  services.rustic = {
    backups = {
      critic = {
        profiles = map (n: config.age.secrets.${n}.path) [
          "general.toml"
          "on-kaambl.toml"
        ];

        timerConfig = {
          OnCalendar = "*-*-* 2,14:00:00";
          RandomizedDelaySec = "4h";
          FixedRandomDelay = true;
          Persistent = true;
        };
      };
      solid = {
        profiles = map (n: config.age.secrets.${n}.path) [
          "general.toml"
          "on-eihort.toml"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 3,15:00:00";
          RandomizedDelaySec = "4h";
          FixedRandomDelay = true;
          Persistent = true;
        };
      };
    };
  };
}
