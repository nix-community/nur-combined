{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.alist;
  settingsFormat = pkgs.formats.json { };
in
{

  meta = {
    maintainers = with lib.maintainers; [ moraxyc ];
  };

  options = {
    services.alist = {
      enable = lib.mkEnableOption "alist, a file list program";
      debug = lib.mkEnableOption "start alist with debug mode";
      user = lib.mkOption {
        type = lib.types.str;
        default = "alist";
        description = "Alist user name.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "alist";
        description = "Alist group name.";
      };

      package = lib.mkPackageOption pkgs "alist" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
          options = {
            force = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                By default AList reads the configuration from environment variables, set this field to true to force AList to read config from the configuration file.
              '';
            };
            site_url = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = ''
                The address of your AList server, such as https://pan.nn.ci. This address is essential for some features, and thus thry may not work properly if unset:
                - thumbnailing LocalStorage
                - previewing site after setting web proxy
                - displaying download address after setting web proxy
                - reverse-proxying to site sub directories
                - ...
                Do not include the slash (/) at the end of the address.
              '';
            };
            cdn = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = ''
                The address of the CDN. Included `$version` values will be dynamically replaced by the version of AList. Existing dist resources are hosted on both npm and GitHub, which can be found at:

                - https://www.npmjs.com/package/alist-web
                - https://github.com/alist-org/web-dist
                Thus it is possible to use any npm or GitHub CDN path for this field. For example:

                - https://registry.npmmirror.com/alist-web/$version/files/dist/
                - https://cdn.jsdelivr.net/npm/alist-web@$version/dist/
                - https://unpkg.com/alist-web@$version/dist/

                Keep empty to use local dist resources.
              '';
            };
            jwt_secret = lib.mkOption {
              type = lib.types.attrsOf lib.types.path;
              example = lib.literalExpression ''
                {
                  _secret = "/run/agenix/alist-jwt";
                };
              '';
              description = ''
                The secret used to sign the JWT token, should be a random string
              '';
            };
            token_expires_in = lib.mkOption {
              type = lib.types.int;
              default = 48;
              description = ''
                User login expiration time, in hours.
              '';
            };
            database = {
              type = lib.mkOption {
                type = lib.types.enum [
                  "sqlite3"
                  "mysql"
                  "postgres"
                ];
                default = "sqlite3";
                description = ''
                  Database type, available options are `sqlite3`, `mysql` and `postgres`.
                '';
              };
              host = lib.mkOption {
                type = lib.types.str;
                default = "";
                example = "127.0.0.1";
                description = "database host";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 0;
                example = 3306;
                description = "database port";
              };
              user = lib.mkOption {
                type = lib.types.str;
                default = "";
                example = "root";
                description = "database account";
              };
              password = lib.mkOption {
                type = lib.types.oneOf [
                  lib.types.str
                  (lib.types.attrsOf lib.types.path)
                ];
                default = "";
                example = lib.literalExpression ''
                  {
                    _secret = /run/agenix/alist-db-password;
                  };
                '';
                description = "database password";
              };
              name = lib.mkOption {
                type = lib.types.str;
                default = "";
                example = "alist";
                description = "database name";
              };
              db_file = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/alist/data/data.db";
                description = "Database location, used by sqlite3";
              };
              table_prefix = lib.mkOption {
                type = lib.types.str;
                default = "x_";
                description = "database table name prefix";
              };
              ssl_mode = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = ''
                  To control the encryption options during the SSL handshake, the parameters can be searched by themselves, or check the answer from ChatGPT on https://alist.nn.ci/config/configuration.html#database
                '';
              };
              dsn = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = ''
                  see https://github.com/alist-org/alist/pull/6031
                '';
              };
            };
            meilisearch = {
              host = lib.mkOption {
                type = lib.types.str;
                default = "http://localhost:7700";
                description = "meilisearch host";
              };
              api_key = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "meilisearch api key";
              };
              index_prefix = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "meilisearch index prefix";
              };
            };
            scheme = {
              address = lib.mkOption {
                type = lib.types.str;
                default = "0.0.0.0";
                description = ''
                  The http/https address to listen on, default `0.0.0.0`
                '';
              };
              http_port = lib.mkOption {
                type = lib.types.ints.between (-1) 65535;
                default = 5244;
                description = ''
                  The http port to listen on, default `5244`, if you want to disable http, set it to `-1`
                '';
              };
              https_port = lib.mkOption {
                type = lib.types.ints.between (-1) 65535;
                default = (-1);
                description = ''
                  The https port to listen on, default `-1`, if you want to enable https, set it to non `-1`
                '';
              };
              force_https = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  Whether the HTTPS protocol is forcibly, if it is set to True, the user can only access the website through HTTPS
                '';
              };
              cert_file = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Path of cert file";
              };
              key_file = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Path of key file";
              };
              unix_file = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = ''
                  Unix socket file path to listen on, default empty, if you want to use unix socket, set it to non empty
                '';
              };
              unix_file_perm = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = ''
                  Unix socket file permission, set to the appropriate permissions
                '';
              };
            };
            temp_dir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/alist/temp";
              description = ''
                The directory to keep temporary files.
                temp_dir is a temporary folder exclusive to alist. In order to prevent AList from generating garbage files when being interrupted, the directory will be cleared every time AList starts, so do not store anything in this directory.
              '';
            };
            bleve_dir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/alist/bleve";
              description = ''
                Where data is stored when using bleve index.
              '';
            };
            dist_dir = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = ''
                 If this item is set, the frontend file of this option is preferred to render, support the use of other frontend files, and the backend continues to use the original application
                 - https://github.com/alist-org/alist/issues/5531
                 - https://github.com/alist-org/alist/discussions/6110
                Upload the frontend file (dist) to the data folder of the application, and then fill in this way. The disadvantage is that if you update each time, you need to change the file manually
              '';
            };
            log = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  Whether AList should store logs
                '';
              };
              name = lib.mkOption {
                type = lib.types.str;
                default = "/var/lib/alist/log/alist.log";
                description = ''
                  The path and name of the log file
                '';
              };
              max_size = lib.mkOption {
                type = lib.types.int;
                default = 50;
                description = ''
                  the maximum size of a single log file, in MB. After reaching the specified size, the file will be automatically split.
                '';
              };
              max_backups = lib.mkOption {
                type = lib.types.int;
                default = 30;
                description = ''
                  the number of log backups to keep. Old backups will be deleted automatically when the limit is exceeded
                '';
              };
              max_age = lib.mkOption {
                type = lib.types.int;
                default = 28;
                description = ''
                  The maximum number of days preserved in the log file, the log file that exceeds the number of days will be deleted
                '';
              };
              compress = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  Whether to enable log file compression functions. After compression, the file size can be reduced, but you need to decompress when viewing, and the default is to close the state false
                '';
              };
            };
            delayed_start = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = ''
                Time unit: second (new feature of v3.19.0)
                Whether to delay AList startup.
                Generally this option is used when AList is configured to auto-start. The reason is that sometimes network takes some time to connect, so drivers requiring cannot start correctly after Alist starts.
              '';
            };
            max_connections = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = ''
                The maximum amount of connections at the same time. The default is 0, which is unlimited.

                - 10 or 20 is recommended for general devices such as n1.
                - Usage Scenarios: the device will crash if the device is bad at concurrency when picture mode is enabled.
              '';
            };
            tls_insecure_skip_verify = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Whether not to verify the SSL certificate. If there is a problem with the certificate of the website used when this option is not enabled (such as not including the intermediate certificate, having the certificate expired, or forging the certificate, etc.), the service will not be available. Run the program in a safe network environment when this option is enabled.
              '';
            };

            tasks = lib.mkOption {
              type = lib.types.attrsOf (lib.types.attrsOf lib.types.int);
              description = "Configuration for background task threads.";
              default = {
                download = {
                  workers = 5;
                  max_retry = 1;
                };
                transfer = {
                  workers = 5;
                  max_retry = 2;
                };
                upload = {
                  workers = 5;
                  max_retry = 0;
                };
                copy = {
                  workers = 5;
                  max_retry = 2;
                };
              };
            };

            cors = {
              allow_origins = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ "*" ];
                description = "Allowed sources.";
              };
              allow_methods = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ "*" ];
                description = "Allowed request methods.";
              };
              allow_headers = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ "*" ];
                description = "Allowed request headers.";
              };
            };

            s3 = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether the S3 function is enabled, the default is not enabled";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 5246;
                description = "S3 port";
              };
              ssl = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable the HTTPS certificate, not enabled by default";
              };
            };
          };
        };
        default = { };
        description = ''
          The alist configuration, see https://alist.nn.ci/config/configuration.html for documentation.

          Options containing secret data should be set to an attribute set containing the attribute `_secret` - a string pointing to a file containing the value the option should be set to.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.alist = lib.optionalAttrs (cfg.user == "alist") {
      description = "Alist user";
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.alist = lib.optionalAttrs (cfg.group == "alist") { };

    environment.systemPackages = [ cfg.package ];

    systemd.services.alist = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        umask 0077
        mkdir -p /var/lib/alist/data
        ${utils.genJqSecretsReplacementSnippet cfg.settings "/var/lib/alist/data/config.json"}
      '';
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "simple";
        ExecStart =
          "${cfg.package}/bin/alist server --data /var/lib/alist/data --log-std"
          + lib.optionalString cfg.debug " --debug";
        Restart = "on-failure";
        RestartSec = "1s";
        StateDirectory = [ "alist" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
  };
}
