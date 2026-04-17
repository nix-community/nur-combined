{ self, ... }:
{
  flake.modules.nixos."backup/hastur" =
    { config, ... }:
    {
      vaultix.secrets = {
        "on-hastur.toml" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/home/elen/Documents" ]
            '';
          };
        };
        "on-eihort.toml" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/var/.snapshots/latest/" ]
            '';
          };
        };
      };
      services.rustic = {
        backups = {
          solid = {
            profiles = map (n: config.vaultix.secrets.${n}.path) [
              "general.toml"
              "on-eihort.toml"
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
    };

  flake.modules.nixos."backup/eihort" =
    { config, ... }:
    {
      imports = [ self.modules.nixos.postgresql-backup ];
      systemd.services.postgresqlBackup.onSuccess = [ "rustic-backups-critic.service" ];

      vaultix.secrets = {
        "on-hastur.toml" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/var/.snapshots/latest/lib/backup/postgresql" ]
            '';
          };
        };
      };
      services.rustic = {
        profiles = map (n: config.vaultix.secrets.${n}.path) [
          "on-hastur.toml"
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
    };
}
