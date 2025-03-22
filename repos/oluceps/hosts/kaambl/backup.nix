{ config, lib, ... }:
{

  vaultix.secrets = {
    "on-hastur.toml" = {
      file = ../../sec/on-hastur.toml.age;
      insert = {
        "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
          [[backup.snapshots]]
          sources = [ "/home/elen/Documents" ]
        '';
      };
    };
    "on-eihort.toml" = {
      file = ../../sec/on-eihort.toml.age;
      cleanPlaceholder = true;
      insert = {
        "0206c8ff3ff866c4212f1a968882f993e101fbf7ffdaa4e0e722b3ca069c5559".content = ''
          [[backup.snapshots]]
          sources = [ "/home/elen/Documents", "/home/elen/Src/blog.nyaw.xyz" ]
        '';
      };
    };
    "on-kaambl.toml" = {
      file = ../../sec/on-kaambl.toml.age;
    };
    "on-yidong.toml" = {
      file = ../../sec/on-yidong.toml.age;
      cleanPlaceholder = true;
    };
  };
  services.rustic = {
    profiles = map (n: config.vaultix.secrets.${n}.path) [
      "general.toml"
      "on-kaambl.toml"
      "on-eihort.toml"
      "on-hastur.toml"
      "on-yidong.toml"
    ];
    backups = {
      critic = {
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
