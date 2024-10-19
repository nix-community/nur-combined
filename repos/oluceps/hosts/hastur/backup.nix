{ config, lib, ... }:
{
  services.rustic = {
    backups = {
      critic = {
        profiles = lib.genAttrs [
          "general.toml"
          "on-kaambl.toml"
        ] (n: config.age.secrets.${n}.path);

        timerConfig = {
          OnCalendar = "*-*-* 2,14:00:00";
          RandomizedDelaySec = "4h";
          FixedRandomDelay = true;
          Persistent = true;
        };
      };
      solid = {
        profiles = lib.genAttrs [
          "general.toml"
          "on-eihort.toml"
        ] (n: config.age.secrets.${n}.path);

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
