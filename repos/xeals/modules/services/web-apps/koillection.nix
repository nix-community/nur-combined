{ config, lib, modulesPath, options, pkgs, ... }:
let
  inherit (lib) literalExpression mkEnableOption mkIf mkOption optionalString types;

  opt = options.services.koillection;
  cfg = config.services.koillection;
  db = cfg.database;

  koillection = (pkgs.koillection or pkgs.callPackage ../../../pkgs/by-name/ko/koillection/package.nix { }).override {
    dataDir = cfg.dataDir;
  };
  inherit (koillection.passthru) phpPackage;
in
{
  options.services.koillection = {
    enable = mkEnableOption "Koillection, a collection manager";

    user = mkOption {
      type = types.str;
      default = "koillection";
      description = lib.mdDoc "User Koillection runs as.";
    };

    group = mkOption {
      type = types.str;
      default = "koillection";
      description = lib.mdDoc "Group Koillection runs as.";
    };

    hostName = lib.mkOption {
      type = types.str;
      default = config.networking.fqdnOrHostName;
      defaultText = "config.networking.fqdnOrHostName";
      example = "koillection.example.com";
      description = lib.mdDoc "The hostname to serve Koillection on.";
    };

    dataDir = mkOption {
      description = lib.mdDoc "Koillection data directory";
      default = "/var/lib/koillection";
      type = types.path;
    };

    database = {
      host = mkOption {
        type = types.str;
        default = if db.createLocally then "/run/postgresql" else null;
        defaultText = literalExpression ''
          if config.${opt.database.createLocally}
          then "/run/postgresql"
          else null
        '';
        example = "192.168.12.85";
        description = lib.mdDoc "Database host address or unix socket.";
      };
      port = mkOption {
        type = types.port;
        default = 5432;
        description = lib.mdDoc "Database host port.";
      };
      name = mkOption {
        type = types.str;
        default = "koillection";
        description = lib.mdDoc "Database name.";
      };
      user = mkOption {
        type = types.str;
        default = cfg.user;
        defaultText = literalExpression "user";
        description = lib.mdDoc "Database username.";
      };
      passwordFile = mkOption {
        type = with types; nullOr path;
        default = null;
        example = "/run/keys/koillection-dbpassword";
        description = lib.mdDoc ''
          A file containing the password corresponding to
          {option}`database.user`.
        '';
      };
      createLocally = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Create the database and database user locally.";
      };
    };

    poolConfig = mkOption {
      type = with types; attrsOf (oneOf [ str int bool ]);
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
      };
      description = lib.mdDoc ''
        Options for the bookstack PHP pool. See the documentation on `php-fpm.conf`
        for details on configuration directives.
      '';
    };

    nginx = mkOption {
      type = types.submodule (
        lib.recursiveUpdate
          (import "${modulesPath}/services/web-servers/nginx/vhost-options.nix" { inherit config lib; })
          { }
      );
      default = { };
      example = literalExpression ''
        {
          serverAliases = [
            "koillection.''${config.networking.domain}"
          ];
          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
        }
      '';
      description = lib.mdDoc ''
        With this option, you can customize the nginx virtualHost settings.
      '';
    };

    config = mkOption {
      type = with types;
        attrsOf
          (nullOr
            (either
              (oneOf [ bool int port path str ])
              (submodule {
                options = {
                  _secret = mkOption {
                    type = nullOr str;
                    description = lib.mdDoc ''
                      The path to a file containing the value the option should
                      be set to in the final configuration file.
                    '';
                  };
                };
              })));
      default = { };
      example = literalExpression ''
      '';
    };
  };

  config = mkIf cfg.enable {
    services.koillection.config = {
      APP_ENV = "prod";
      # DB_DRIVER = "pdo_pgsql";
      DB_USER = db.user;
      DB_PASSWORD._secret = db.passwordFile;
      DB_HOST = db.host;
      DB_PORT = db.port;
      DB_NAME = db.name;
      # FIXME
      # DB_VERSION = lib.versions.major config.services.postgresql.package.version;
      DB_VERSION = "15";
      PHP_TZ = config.time.timeZone;
    };

    services.postgresql = mkIf db.createLocally {
      enable = true;
      ensureDatabases = [ db.name ];
      ensureUsers = [{
        name = db.user;
        ensureDBOwnership = true;
      }];
    };

    services.phpfpm.pools.koillection = {
      inherit (cfg) user group;
      inherit phpPackage;
      # Copied from docker/php.ini
      phpOptions = ''
        max_execution_time = 200

        apc.enabled = 1
        apc.shm_size = 64M
        apc.ttl = 7200

        opcache.enable = 1
        opcache.memory_consumption = 256
        opcache.max_accelerated_files = 20000
        opcache.max_wasted_percentage = 10
        opcache.validate_timestamps = 0
        opcache.preload = ${koillection}/share/php/koillection/config/preload.php
        opcache.preload_user = ${cfg.user}
        expose_php = Off

        session.cookie_httponly = 1
        realpath_cache_size = 4096K
        realpath_cache_ttle = 600
      '';
      settings = {
        "listen.mode" = "0660";
        "listen.owner" = cfg.user;
        "listen.group" = cfg.group;
      } // cfg.poolConfig;
    };

    services.nginx = {
      enable = lib.mkDefault true;
      virtualHosts."${cfg.hostName}" = lib.mkMerge [
        cfg.nginx
        {
          root = lib.mkForce "${koillection}/share/php/koillection/public";
          extraConfig = optionalString (cfg.nginx.addSSL || cfg.nginx.forceSSL || cfg.nginx.onlySSL || cfg.nginx.enableACME) "fastcgi_param HTTPS on;";
          locations = {
            "/" = {
              index = "index.php";
              extraConfig = ''try_files $uri $uri/ /index.php?query_string;'';
            };
            "~ \.php$" = {
              extraConfig = ''
                try_files $uri $uri/ /index.php?$query_string;
                include ${config.services.nginx.package}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param REDIRECT_STATUS 200;
                fastcgi_pass unix:${config.services.phpfpm.pools."koillection".socket};
                ${optionalString (cfg.nginx.addSSL || cfg.nginx.forceSSL || cfg.nginx.onlySSL || cfg.nginx.enableACME) "fastcgi_param HTTPS on;"}
              '';
            };
            "~ \.(js|css|gif|png|ico|jpg|jpeg)$" = {
              extraConfig = "expires 365d;";
            };
          };
        }
      ];
    };

    systemd.services.koillection-setup = {
      description = "Preparation tasks for koillection";
      before = [ "phpfpm-koillection.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = cfg.user;
        WorkingDirectory = koillection;
        RuntimeDirectory = "koillection/cache";
        RuntimeDirectoryMode = "0700";
      };
      path = [ pkgs.replace-secret ];
      script =
        let
          isSecret = v: lib.isAttrs v && v ? _secret && lib.isString v._secret;
          koillectionEnvVars = lib.generators.toKeyValue {
            mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
              mkValueString = v: with builtins;
                if isInt v then toString v
                else if lib.isString v then v
                else if true == v then "true"
                else if false == v then "false"
                else if isSecret v then hashString "sha256" v._secret
                else throw "unsupported type ${typeOf v}: ${(lib.generators.toPretty {}) v}";
            };
          };
          secretPaths = lib.mapAttrsToList (_: v: v._secret) (lib.filterAttrs (_: isSecret) cfg.config);
          mkSecretReplacement = file: ''
            replace-secret ${lib.escapeShellArgs [ ( builtins.hashString "sha256" file ) file "${cfg.dataDir}/.env" ]}
          '';
          secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;
          filteredConfig = lib.converge (lib.filterAttrsRecursive (_: v: ! builtins.elem v [{ } null])) cfg.config;
          koillectionEnv = pkgs.writeText "koillection.env" (koillectionEnvVars filteredConfig);
        in
        ''
          # error handling
          set -euo pipefail

          # set permissions
          umask 077

          # create .env file
          install -T -m 0600 -o ${cfg.user} ${koillectionEnv} "${cfg.dataDir}/.env"
          ${secretReplacements}

          # prepend `base64:` if it does not exist in APP_KEY

          if ! grep 'APP_KEY=base64:' "${cfg.dataDir}/.env" >/dev/null; then
              sed -i 's/APP_KEY=/APP_KEY=base64:/' "${cfg.dataDir}/.env"
          fi

          # migrate db
          ${lib.getExe phpPackage} ${koillection}/share/php/koillection/bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

          # dump translations
          # TODO: Might need pointing somewhere else.
          ${lib.getExe phpPackage} ${koillection}/share/php/koillection/bin/console app:translations:dump
        '';
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0710 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/public                     0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/public/uploads             0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/var                        0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/var/cache                  0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/var/cache/prod             0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/var/logs                   0700 ${cfg.user} ${cfg.group} - -"
    ];

    users = {
      users = mkIf (cfg.user == "koillection") {
        koillection = {
          inherit (cfg) group;
          isSystemUser = true;
        };
        "${config.services.nginx.user}".extraGroups = [ cfg.group ];
      };
      groups = mkIf (cfg.group == "koillection") {
        koillection = { };
      };
    };
  };
}
