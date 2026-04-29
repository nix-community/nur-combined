{ self, ... }:
{
  flake.modules.nixos."backup/hastur" =
    { config, ... }:
    {
      vaultix.secrets = {
        "on-hastur" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/home/riro/Documents" ]
            '';
          };
          name = "on-hastur.toml";
        };
        "on-eihort" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/var/" ]
            '';
          };
          name = "on-eihort.toml";
        };
        general = {
          name = "general.toml";
        };
      };
      services.rustic = {
        backups = {
          solid = {
            profiles = map (n: config.vaultix.secrets.${n}.path) [
              "general"
              "on-eihort"
              "on-hastur"
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
        "on-hastur" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/var/.snapshots/latest/lib/backup/postgresql" ]
            '';
          };
          name = "on-hastur.toml";
        };
        "on-coldarch" = {
          insert = {
            "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
              [[backup.snapshots]]
              sources = [ "/var/lib/backup/postgresql/all.sql" ]
            '';
          };
          name = "on-coldarch.toml";
        };
        general = {
          name = "general.toml";
        };
      };
      services.rustic = {
        profiles = map (n: config.vaultix.secrets.${n}.path) [
          "on-hastur"
          "on-coldarch"
        ];
        backups = {
          critic = {
            profiles = map (n: config.vaultix.secrets.${n}.path) [
              "general"
              "on-hastur"
            ];
            timerConfig = {
              OnCalendar = "*-*-1/3 03:00:00";
              RandomizedDelaySec = "4h";
              FixedRandomDelay = true;
              Persistent = true;
            };
          };
          supercold = {
            profiles = map (n: config.vaultix.secrets.${n}.path) [
              "on-coldarch"
            ];
            timerConfig = {
              OnCalendar = "weekly";
              RandomizedDelaySec = "4h";
              FixedRandomDelay = true;
              Persistent = true;
            };
          };
        };
      };
    };
}
