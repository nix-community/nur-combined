{ config, lib, ... }: with lib; let
  mutableStateModule = { nixosConfig, name, ... }: {
    config = {
      serviceNames = mkIf (nixosConfig.systemd.services ? ${name}) [ name ];
      owner = mkIf (nixosConfig.users.users ? ${name}) (mkDefault name);
      group = mkIf (nixosConfig.users.groups ? ${name}) (mkDefault name);
    };
  };
in {
  options.system.mutableState = {
    services = mkOption {
      type = types.attrsOf (types.submodule [
        ../misc/mutable-state.nix
        mutableStateModule
        ({ ... }: {
          _module.args = rec {
            nixosConfig = config;
            osConfig = nixosConfig;
          };
        })
      ]);
      default = { };
    };
  };
  config = {
    system.mutableState.services = {
      bitlbee = {
        enable = mkDefault config.services.bitlbee.enable;
        paths = [ config.services.bitlbee.configDir ];
      };
      prosody = {
        enable = mkDefault config.services.prosody.enable;
        databases.postgresql = mkIf (config.services.postgresql.enable) [ "prosody" ];
        paths = singleton config.services.prosody.dataDir;
      };
      matrix-synapse = {
        enable = mkDefault config.services.matrix-synapse.enable;
        databases.postgresql = mkIf (config.services.matrix-synapse.settings.database.name == "psycopg2" && config.services.postgresql.enable) [ "matrix-synapse" ];
        paths = singleton {
          path = config.services.matrix-synapse.dataDir;
          exclude = [
            "media/local_thumbnails"
            "media/remote_thumbnail"
            "media/url_cache"
            "media/url_cache_thumbnails"
          ];
        };
      };
      vaultwarden = {
        enable = mkDefault config.services.vaultwarden.enable;
        name = mkDefault "vaultwarden";
        databases.postgresql = mkIf (config.services.vaultwarden.dbBackend == "postgresql" && config.services.postgresql.enable) [ "vaultwarden" ];
        paths = singleton {
          path = config.services.vaultwarden.config.dataFolder or "/var/lib/bitwarden_rs";
          exclude = [
            "icon_cache"
          ];
          excludeExtract = [
            "config.json"
          ];
        };
      };
      gitolite = {
        enable = mkDefault config.services.gitolite.enable;
        paths = singleton {
          path = config.services.gitolite.dataDir;
          excludeExtract = [
            ".gitolite.rc"
            ".gitolite"
            ".ssh"
          ];
        };
      };
      taskserver = {
        enable = mkDefault config.services.taskserver.enable;
        paths = singleton {
          path = config.services.taskserver.dataDir;
          owner = config.services.taskserver.user;
          group = config.services.taskserver.group;
          excludeExtract = [
            "config"
            "*.pem"
            "generate*"
            "vars"
          ];
        };
      };
    };
  };
}
