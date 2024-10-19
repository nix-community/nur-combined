{ config, lib, ... }:
{
  services.rustic = {
    backups = {
      critic = {
        profiles = [
          "general"
          "on-kaambl"
        ];
       credentials = (
          (map (lib.genCredPath config)) [
            "general.toml"
            "on-kaambl.toml"
          ]
        );

        timerConfig = {
          OnCalendar = "*-*-* 2,14:00:00";
          RandomizedDelaySec = "4h";
          FixedRandomDelay = true;
          Persistent = true;
        };
      };
    };
  };
}
