{ config, lib, ... }:
{
  services.rustic = {
    backups = {
      # solid = {
      #   profiles = lib.genAttrs [
      #     "general.toml"
      #     "on-eihort.toml"
      #   ] (n: config.age.secrets.${n}.path);

      #   timerConfig = {
      #     OnCalendar = "*-*-* 3,15:00:00";
      #     RandomizedDelaySec = "4h";
      #     FixedRandomDelay = true;
      #     Persistent = true;
      #   };
      # };
    };
  };
}
