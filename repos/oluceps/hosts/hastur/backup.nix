{ config, lib, ... }:
{
  # repack.postgresql-backup.enable = true;
  vaultix.secrets = {
    "on-eihort.toml" = {
      file = ../../sec/on-eihort.toml.age;
      insert = {
        "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
          [[backup.snapshots]]
          sources = [ "/var/.snapshots/latest/" ]
        '';
      };
    };
    # "on-kaambl.toml" = {
    #   file = ../../sec/on-kaambl.toml.age;
    # };
  };
  systemd.services.postgresqlBackup.onSuccess = [ "rustic-backups-critic.service" ];
  services.rustic = {
    backups = {
      # critic = {
      #   profiles = map (n: config.vaultix.secrets.${n}.path) [
      #     "general.toml"
      #     "on-kaambl.toml"
      #   ];
      #   timerConfig = null;
      # };

      solid = {
        profiles = map (n: config.vaultix.secrets.${n}.path) [
          "general.toml"
          "on-eihort.toml"
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
