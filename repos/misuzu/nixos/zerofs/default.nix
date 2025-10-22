{
  config,
  lib,
  pkgs,
  ...
}:
let
  instances = config.services.zerofs;
  settingsFormat = pkgs.formats.toml { };
in
{
  options = {
    services.zerofs = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              enable = lib.mkEnableOption "ZeroFS - The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
              package = lib.mkOption {
                type = lib.types.package;
                default = pkgs.zerofs;
                defaultText = "pkgs.zerofs";
                description = "The package to use for ZeroFS.";
              };
              settings = lib.mkOption {
                type = lib.types.submodule {
                  freeformType = settingsFormat.type;
                  options = {
                    cache = {
                      dir = lib.mkOption {
                        type = lib.types.str;
                        default = "\${CACHE_DIRECTORY}";
                        description = "Directory for caching data.";
                      };
                      disk_size_gb = lib.mkOption {
                        type = lib.types.float;
                        default = 10.0;
                        description = "Maximum disk cache size in GB.";
                      };
                      memory_size_gb = lib.mkOption {
                        type = lib.types.nullOr lib.types.float;
                        default = 2.0;
                        description = "Memory cache size in GB (optional).";
                      };
                    };
                    storage = {
                      url = lib.mkOption {
                        type = lib.types.str;
                        description = "Storage backend URL.";
                      };
                      encryption_password = lib.mkOption {
                        type = lib.types.str;
                        description = "Encryption password. Should be at least 8 characters long.";
                      };
                    };
                  };
                };
                default = { };
                example = {
                  storage = {
                    url = "s3://my-bucket/data";
                    encryption_password = "\${ZEROFS_PASSWORD}";
                  };
                  aws = {
                    access_key_id = "\${AWS_ACCESS_KEY_ID}";
                    secret_access_key = "\${AWS_SECRET_ACCESS_KEY}";
                  };
                  servers.ninep = {
                    addresses = [ "0.0.0.0:5564" ];
                  };
                };
                description = ''
                  The ZeroFS config.

                  See documentation <https://www.zerofs.net/configuration#configuration-file-structure>.
                '';
              };
              configFile = lib.mkOption {
                type = lib.types.path;
                default = settingsFormat.generate "zerofs-${name}.toml" (
                  lib.filterAttrsRecursive (name: value: value != null) instances.${name}.settings
                );
                defaultText = ''
                  settingsFormat.generate "zerofs-\${name}.toml" (
                    lib.filterAttrsRecursive (name: value: value != null) instances.\${name}.settings
                  )
                '';
                description = ''
                  The config file of ZeroFS.

                  Setting this option will override any configuration applied by the settings option.
                '';
              };
              environmentFile = lib.mkOption {
                type = with lib.types; nullOr path;
                default = null;
                description = ''
                  Environment file as defined in {manpage}`systemd.exec(5)`.

                  See documentation <https://www.zerofs.net/configuration#environment-variable-substitution>.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = "ZeroFS instances.";
      example = {
        z01 = {
          enable = true;
          settings = {
            storage = {
              url = "s3://my-bucket/data";
              encryption_password = "\${ZEROFS_PASSWORD}";
            };
            aws = {
              access_key_id = "\${AWS_ACCESS_KEY_ID}";
              secret_access_key = "\${AWS_SECRET_ACCESS_KEY}";
            };
            servers.ninep.addresses = [ "0.0.0.0:15564" ];
            servers.nbd.addresses = [ "0.0.0.0:10809" ];
          };
          environmentFile = "/run/secrets/zerofs-z01.env";
        };
        z02 = {
          enable = true;
          settings = {
            storage = {
              url = "file://\${STATE_DIRECTORY}/data";
              encryption_password = "\${ZEROFS_PASSWORD}";
            };
            servers.ninep.addresses = [ "0.0.0.0:25564" ];
            servers.nbd.addresses = [ "0.0.0.0:20809" ];
          };
          environmentFile = "/run/secrets/zerofs-z02.env";
        };
      };
    };
  };
  config = {
    systemd.services = lib.mapAttrs' (
      name: cfg:
      lib.nameValuePair "zerofs-${name}" ({
        description = "ZeroFS (instance ${name})";
        after = [
          "network.target"
          "network-online.target"
        ];
        wants = [
          "network.target"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${lib.getExe cfg.package} run -c ${cfg.configFile}";
          Restart = "always";
          RestartSec = "5s";
          DynamicUser = true;
          Group = "zerofs";
          User = "zerofs";
          CacheDirectory = "zerofs-${name}";
          StateDirectory = "zerofs-${name}";
          WorkingDirectory = "/var/lib/zerofs-${name}";
        };
      })
    ) (lib.filterAttrs (n: v: v.enable) instances);
  };
}
