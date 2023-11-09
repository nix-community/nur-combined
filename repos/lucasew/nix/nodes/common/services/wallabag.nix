{ config, pkgs, lib, ... }:

# based on code from https://github.com/dwarfmaster/home-nix/blob/da78839296eb3ad4ebdda25832eeda353fc48bf5/profiles/nixos/web/wallabag/default.nix
let
  cfg = config.services.wallabag;

  yaml = pkgs.formats.yaml {};

  exts = pkgs.php.extensions;
  php = pkgs.php.withExtensions ({ enabled, all }: enabled ++ (with all; [
    # imagick
    # tidy
    # pdo
    # pdo_pgsql
    # session
    # ctype
    # dom
    # simplexml
    # gd
    # mbstring
    # xml
    # iconv
    # curl
    # gettext
    # tokenizer
    # bcmath
    # intl
  ]));

  dataDir = "/var/lib/wallabag";

  domain = "wallabag.${config.networking.hostName}.${config.networking.domain}";
in

{
  options = {
    services.wallabag = {
      enable = lib.mkEnableOption "wallabag";
      settings = lib.mkOption {
        description = "Wallabag settings";
        type = yaml.type;
        default = {};
      };
      package = lib.mkPackageOption pkgs "wallabag" {};
    };
  };
  config = lib.mkIf cfg.enable {
    networking.ports.wallabag.enable = true;

    environment.etc."wallabag".source = pkgs.buildEnv {
      name = "wallabag-app-dir";
      ignoreCollisions = true;
      checkCollisionContents = false;
      paths = [
        (pkgs.runCommand "wallabag_parameters" {preferLocalBuild = true;} ''
          mkdir -p $out/config
          ln -s ${yaml.generate "parameters.yaml" {parameters = config.services.wallabag.settings; }} $out/config/parameters.yml
        '')
        "${cfg.package}/app"      
      ];
    };

    services.wallabag.settings = {
      database_driver = "pdo_pqsql";
      database_host = null;
      database_port = 5432;
      database_name = "wallabag";
      database_user = "wallabag";
      database_password = null;
      database_path = null;
      database_table_prefix = null;
      database_socket = "/run/postgresql";
      database_charset = "utf8";

      domain_name = "http://${domain}";
      server_name = "Wallabag";

      # Needs an explicit command since Symfony version used by Wallabag does not yet support the `native` transport
      # and the `sendmail` transport does not respect `sendmail_path` configured in `php.ini`.
      mailer_dsn = "sendmail://default?command=/run/wrappers/bin/sendmail%%20-t%%20-i";

      locale = "pt_BR";
      "env(SECRET_FILE)" = "/etc/machine-id";
      secret = "%env(file:resolve:SECRET_FILE)%";
      twofactor_auth = false;
      # RabbitMQ processing
      rabbitmq_host = null;
      rabbitmq_port = null;
      rabbitmq_user = null;
      rabbitmq_password = null;
      rabbitmq_prefetch_count = null;

      # Redis processing
      redis_scheme = null;
      redis_host = null;
      redis_port = null;
      redis_path = null;
      redis_password = null;

      # sentry logging
      sentry_dsn = null;
    };
    services.nginx.virtualHosts."${domain}" = {
      root = "${cfg.package}/web";
      locations."/" = {
        priority = 10;
        tryFiles = "$uri /app.php$is_args$args";
      };
      locations."~ ^/app\\.php(/|$)" = {
        priority = 100;
        fastcgiParams = {
          SCRIPT_FILENAME = "$realpath_root$fastcgi_script_name";
          DOCUMENT_ROOT = "$realpath_root";
        };
        extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.wallabag.socket};
          include ${config.services.nginx.package}/conf/fastcgi_params;
          include ${config.services.nginx.package}/conf/fastcgi.conf;
          internal;
        '';
      };
      locations."~ \\.php$" = {
        priority = 1000;
        return = "404";
      };

      extraConfig = ''
        error_log /var/log/nginx/wallabag_error.log;
        access_log /var/log/nginx/wallabag_access.log;
      '';
    };

    services.phpfpm.pools.wallabag = {
      user = "wallabag";
      group = "wallabag";
      phpPackage = php;
      phpEnv = {
        WALLABAG_DATA = "/data/var/www/wallabag";
        PATH = lib.makeBinPath [php];
      };
      settings = {
        "listen.owner" = config.services.nginx.user;
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.start_servers" = 1;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 5;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };
      phpOptions = ''
        extension=${exts.pdo}/lib/php/extensions/pdo.so
        extension=${exts.pdo_pgsql}/lib/php/extensions/pdo_pgsql.so
        extension=${exts.session}/lib/php/extensions/session.so
        extension=${exts.ctype}/lib/php/extensions/ctype.so
        extension=${exts.dom}/lib/php/extensions/dom.so
        extension=${exts.simplexml}/lib/php/extensions/simplexml.so
        extension=${exts.gd}/lib/php/extensions/gd.so
        extension=${exts.mbstring}/lib/php/extensions/mbstring.so
        extension=${exts.xml}/lib/php/extensions/xml.so
        extension=${exts.tidy}/lib/php/extensions/tidy.so
        extension=${exts.iconv}/lib/php/extensions/iconv.so
        extension=${exts.curl}/lib/php/extensions/curl.so
        extension=${exts.gettext}/lib/php/extensions/gettext.so
        extension=${exts.tokenizer}/lib/php/extensions/tokenizer.so
        extension=${exts.bcmath}/lib/php/extensions/bcmath.so
        extension=${exts.intl}/lib/php/extensions/intl.so
        extension=${exts.opcache}/lib/php/extensions/opcache.so
      '';
  };

  # PostgreSQL Database
  services.postgresql = {
    ensureDatabases = ["wallabag"];
    # Wallabag does not support passwordless login into database,
    # so the database password for the user must be manually set
    ensureUsers = [
      {
        name = "wallabag";
        ensurePermissions."DATABASE wallabag" = "ALL PRIVILEGES";
      }
    ];
  };

  # Data directory
  systemd.tmpfiles.rules = let
    user = "wallabag";
  in ["d ${dataDir} 0700 ${user} ${user} - -"];

  systemd.services."wallabag-setup" = {
    description = "Wallabag install service";
    wantedBy = ["multi-user.target"];
    before = ["phpfpm-wallabag.service"];
    requiredBy = ["phpfpm-wallabag.service"];
    after = ["postgresql.service"];
    path = [pkgs.coreutils php pkgs.php.packages.composer];

    serviceConfig = {
      User = "wallabag";
      Group = "wallabag";
      Type = "oneshot";
      RemainAfterExit = "yes";
      PermissionsStartOnly = true;
      Environment = "WALLABAG_DATA=${dataDir}";
    };

    script = ''
      echo "Setting up wallabag files in ${dataDir} ..."
      cd "${dataDir}"

      rm -rf var/cache/*
      rm -f app
      ln -s /etc/wallabag app
      ln -sf ${cfg.package}/composer.{json,lock} .
      ln -sf ${cfg.package}/src .

      if [ ! -f installed ]; then
        echo "Installing wallabag"
        php ${cfg.package}/bin/console --env=prod wallabag:install --no-interaction
        touch installed
      else
        php ${cfg.package}/bin/console --env=prod doctrine:migrations:migrate --no-interaction
      fi
      php ${cfg.package}/bin/console --env=prod cache:clear
    '';
    };
    users.users.wallabag = {
      isSystemUser = true;
      group = "wallabag";
    };
    users.groups.wallabag = {};

  };
}
