{ config, pkgs, lib, ... }:

with lib;

let

  eachSite = config.services.wordpress;
  user = "wordpress";
  group = "wordpress";
  stateDir = name: "/var/lib/wordpress/${name}";

  robots = pkgs.writeText "robots.txt" ''
    User-agent: *
    Disallow: /wp-admin/
    Disallow: /wp-login.php
  '';

  pkg = name: cfg:
    pkgs.stdenv.mkDerivation rec {
      pname = "wordpress-${cfg.hostName}";
      version = src.version;
      src = cfg.package;

      installPhase = ''
        mkdir -p $out
        cp -r * $out/

        # symlink robots.txt
        ln -s ${robots} $out/share/wordpress/robots.txt

        # symlink the wordpress config
        ln -s ${wpConfig name cfg} $out/share/wordpress/wp-config.php

        # symlink uploads directory
        ln -s ${cfg.uploadsDir} $out/share/wordpress/wp-content/uploads

        # https://github.com/NixOS/nixpkgs/pull/53399
        #
        # Symlinking works for most plugins and themes, but Avada, for instance, fails to
        # understand the symlink, causing its file path stripping to fail. This results in
        # requests that look like: https://example.com/wp-content//nix/store/...plugin/path/some-file.js
        # Since hard linking directories is not allowed, copying is the next best thing.

        # copy or link themes and plugins.
        ${if cfg.themesPath == null then
          flip concatMapStringsSep (cfg.themes "\n" (theme:
            "cp -r ${theme} $out/share/wordpress/wp-content/themes/${theme.name}"))
        else ''
          rm -fr $out/share/wordpress/wp-content/themes
          ln -sf ${cfg.themesPath} $out/share/wordpress/wp-content/themes
        ''}

        ${if cfg.pluginsPath == null then
          flip (concatMapStringsSep cfg.plugins "\n" (plugin:
            "cp -r ${theme} $out/share/wordpress/wp-content/plugins/${plugin.name}"))
        else ''
          rm -fr $out/share/wordpress/wp-content/plugins
          ln -sf ${cfg.pluginsPath} $out/share/wordpress/wp-content/plugins
        ''}
      '';
    };

  wpConfig = name: cfg:
    pkgs.writeText "wp-config-${cfg.hostName}.php" ''
      <?php
        define('DB_NAME', '${cfg.database.name}');
        define('DB_HOST', '${cfg.database.host}:${
          if cfg.database.socket != null then
            cfg.database.socket
          else
            toString cfg.database.port
        }');
        define('DB_USER', '${cfg.database.user}');
        ${
          optionalString (cfg.database.passwordFile != null)
          "define('DB_PASSWORD', file_get_contents('${cfg.database.passwordFile}'));"
        }
        define('DB_CHARSET', 'utf8');
        $table_prefix  = '${cfg.database.tablePrefix}';

        require_once('${stateDir name}/secret-keys.php');

        # wordpress is installed onto a read-only file system
        define('DISALLOW_FILE_EDIT', true);
        define('AUTOMATIC_UPDATER_DISABLED', true);

        ${cfg.extraConfig}

        if ( !defined('ABSPATH') )
          define('ABSPATH', dirname(__FILE__) . '/');

        require_once(ABSPATH . 'wp-settings.php');
      ?>
    '';

  secretsVars = [
    "AUTH_KEY"
    "SECURE_AUTH_KEY"
    "LOOGGED_IN_KEY"
    "NONCE_KEY"
    "AUTH_SALT"
    "SECURE_AUTH_SALT"
    "LOGGED_IN_SALT"
    "NONCE_SALT"
  ];
  secretsScript = hostStateDir: ''
    if ! test -e "${hostStateDir}/secret-keys.php"; then
      umask 0177
      echo "<?php" >> "${hostStateDir}/secret-keys.php"
      ${
        concatMapStringsSep "\n" (var: ''
          echo "define('${var}', '`tr -dc a-zA-Z0-9 </dev/urandom | head -c 64`');" >> "${hostStateDir}/secret-keys.php"
        '') secretsVars
      }
      echo "?>" >> "${hostStateDir}/secret-keys.php"
      chmod 440 "${hostStateDir}/secret-keys.php"
    fi
  '';

  phpPackage = cfg:
    let base = pkgs.php74;
    in base.buildEnv { extraConfig = phpOptionsStr cfg; };

  toKeyValue = generators.toKeyValue {
    mkKeyValue = generators.mkKeyValueDefault { } " = ";
  };

  phpOptions = cfg:
    {
      upload_max_filesize = cfg.maxUploadSize;
      post_max_size = cfg.maxUploadSize;
      memory_limit = cfg.maxUploadSize;
    } // cfg.phpOptions;
  phpOptionsStr = cfg: toKeyValue (phpOptions cfg);

  siteOpts = { lib, name, ... }: {
    options = {
      package = mkOption {
        type = types.package;
        default = pkgs.wordpress;
        description = "Which WordPress package to use.";
      };

      uploadsDir = mkOption {
        type = types.path;
        default = "${stateDir name}/uploads";
        description = ''
          This directory is used for uploads of pictures. The directory passed here is automatically
          created and permissions adjusted as required.
        '';
      };

      pluginsPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to the directory containing the plugins.
          This option can't be used together with 'plugins'.
        '';
      };

      plugins = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          List of path(s) to respective plugin(s) which are copied from the 'plugins' directory.
          <note><para>These plugins need to be packaged before use, see example.</para></note>
        '';
        example = ''
          # Wordpress plugin 'embed-pdf-viewer' installation example
          embedPdfViewerPlugin = pkgs.stdenv.mkDerivation {
            name = "embed-pdf-viewer-plugin";
            # Download the theme from the wordpress site
            src = pkgs.fetchurl {
              url = "https://downloads.wordpress.org/plugin/embed-pdf-viewer.2.0.3.zip";
              sha256 = "1rhba5h5fjlhy8p05zf0p14c9iagfh96y91r36ni0rmk6y891lyd";
            };
            # We need unzip to build this package
            buildInputs = [ pkgs.unzip ];
            # Installing simply means copying all files to the output directory
            installPhase = "mkdir -p $out; cp -R * $out/";
          };

          And then pass this theme to the themes list like this:
            plugins = [ embedPdfViewerPlugin ];
        '';
      };

      themesPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to the directory containing the themes.
          This option can't be used together with 'themes'.
        '';
      };

      themes = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          List of path(s) to respective theme(s) which are copied from the 'theme' directory.
          <note><para>These themes need to be packaged before use, see example.</para></note>
        '';
        example = ''
          # Let's package the responsive theme
          responsiveTheme = pkgs.stdenv.mkDerivation {
            name = "responsive-theme";
            # Download the theme from the wordpress site
            src = pkgs.fetchurl {
              url = "https://downloads.wordpress.org/theme/responsive.3.14.zip";
              sha256 = "0rjwm811f4aa4q43r77zxlpklyb85q08f9c8ns2akcarrvj5ydx3";
            };
            # We need unzip to build this package
            buildInputs = [ pkgs.unzip ];
            # Installing simply means copying all files to the output directory
            installPhase = "mkdir -p $out; cp -R * $out/";
          };

          And then pass this theme to the themes list like this:
            themes = [ responsiveTheme ];
        '';
      };

      database = {
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = "Database host address.";
        };

        port = mkOption {
          type = types.port;
          default = 3306;
          description = "Database host port.";
        };

        name = mkOption {
          type = types.str;
          default = "wordpress";
          description = "Database name.";
        };

        user = mkOption {
          type = types.str;
          default = "wordpress";
          description = "Database user.";
        };

        passwordFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          example = "/run/keys/wordpress-dbpassword";
          description = ''
            A file containing the password corresponding to
            <option>database.user</option>.
          '';
        };

        tablePrefix = mkOption {
          type = types.str;
          default = "wp_";
          description = ''
            The $table_prefix is the value placed in the front of your database tables.
            Change the value if you want to use something other than wp_ for your database
            prefix. Typically this is changed if you are installing multiple WordPress blogs
            in the same database.

            See <link xlink:href='https://codex.wordpress.org/Editing_wp-config.php#table_prefix'/>.
          '';
        };

        socket = mkOption {
          type = types.nullOr types.path;
          default = null;
          defaultText = "/run/mysqld/mysqld.sock";
          description =
            "Path to the unix socket file to use for authentication.";
        };

        createLocally = mkOption {
          type = types.bool;
          default = true;
          description = "Create the database and database user locally.";
        };
      };

      hostName = mkOption {
        type = types.str;
        example = "wordpress.local";
        description = "Hostname for this wordpress installation";
      };

      https = mkOption {
        type = types.bool;
        default = true;
      };

      # From the nextcloud service.
      phpOptions = mkOption {
        type = types.attrsOf types.str;
        default = {
          short_open_tag = "Off";
          expose_php = "Off";
          error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
          display_errors = "stderr";
          "opcache.enable_cli" = "1";
          "opcache.interned_strings_buffer" = "8";
          "opcache.max_accelerated_files" = "10000";
          "opcache.memory_consumption" = "128";
          "opcache.revalidate_freq" = "1";
          "opcache.fast_shutdown" = "1";
          "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
          catch_workers_output = "yes";
        };
        description = ''
          Options for PHP's php.ini file for nextcloud.
        '';
      };

      maxUploadSize = mkOption {
        default = "128M";
        type = types.str;
        description = ''
          Defines the upload limit for files. This changes the relevant options
          in php.ini and nginx if enabled.
        '';
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
        description = ''
          Options for the WordPress PHP pool. See the documentation on <literal>php-fpm.conf</literal>
          for details on configuration directives.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Any additional text to be appended to the wp-config.php
          configuration file. This is a PHP script. For configuration
          settings, see <link xlink:href='https://codex.wordpress.org/Editing_wp-config.php'/>.
        '';
        example = ''
          define( 'AUTOSAVE_INTERVAL', 60 ); // Seconds
        '';
      };
    };

    config.hostName = mkDefault name;
  };
in {
  # interface
  options = {
    services.wordpress = mkOption {
      type = types.attrsOf (types.submodule siteOpts);
      default = { };
      description =
        "Specification of one or more WordPress sites to serve via NGINX.";
    };
  };

  # implementation
  config = mkIf (eachSite != { }) {

    assertions = concatLists (mapAttrsToList (hostName: cfg: [
      {
        assertion = cfg.database.createLocally -> cfg.database.user == user;
        message =
          "services.wordpress.${hostName}.database.user must be ${user} if the database is to be automatically provisioned";
      }
      {
        assertion = cfg.pluginsPath != null -> cfg.plugins == [ ];
        message =
          "services.wordpress.${hostName}.pluginsPath and plugins can't both be set.";
      }
      {
        assertion = cfg.themesPath != null -> cfg.themes == [ ];
        message =
          "services.wordpress.${hostName}.themesPath and themes can't both be set.";
      }
    ]) eachSite);

    services.mysql =
      mkIf (any (v: v.database.createLocally) (attrValues eachSite)) {
        enable = true;
        ensureDatabases =
          mapAttrsToList (name: cfg: cfg.database.name) eachSite;
        ensureUsers = mapAttrsToList (name: cfg: {
          name = cfg.database.user;
          ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
        }) eachSite;
      };

    services.phpfpm.pools = mapAttrs' (name: cfg:
      (nameValuePair "wordpress-${name}" {
        inherit user group;
        phpOptions = phpOptionsStr cfg;
        phpPackage = phpPackage cfg;
        phpEnv = {
          PATH =
            "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin";
        };
        settings = {
          "listen.owner" = config.services.nginx.user;
          "listen.group" = config.services.nginx.group;
        } // cfg.poolConfig;
      })) eachSite;

    services.nginx.enable = mkDefault true;

    services.nginx.virtualHosts = flip mapAttrs' eachSite (name: cfg:
      let
        value = {
          root = "${pkg name cfg}/share/wordpress";
          locations = {
            "= /favicon.ico" = {
              extraConfig = ''
                log_not_found off;
                access_log off;
              '';
            };
            "= /robots.txt" = {
              extraConfig = ''
                allow all;
                log_not_found off;
                access_log off;
              '';
            };
            "/" = {
              extraConfig = ''
                # This is cool because no php is touched for static content.
                # include the "?$args" part so non-default permalinks doesn't break when using query string
                try_files $uri $uri/ /index.php?$args;
              '';
            };
            "~ .php$" = {
              priority = 100;
              extraConfig = ''
                include ${config.services.nginx.package}/conf/fastcgi.conf;
                fastcgi_pass unix:${
                  config.services.phpfpm.pools."wordpress-${name}".socket
                };
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param HTTPS ${if cfg.https then "on" else "off"};
                fastcgi_param modHeadersAvailable true;
                fastcgi_param front_controller_active true;
                fastcgi_intercept_errors on;
                fastcgi_request_buffering off;
                fastcgi_read_timeout 120s;
              '';
            };
            "~* .(js|css|png|jpg|jpeg|gif|ico)$" = {
              extraConfig = ''
                expires max;
                log_not_found off;
              '';
            };
            # Hardening
            "~* /(xmlrpc|wp-config).php$" = {
              priority = 900;
              extraConfig = "deny all;";
            };
            # Deny access to any files with a .php extension in the uploads directory.
            "~* /(?:uploads|files)/.*.php$" = {
              priority = 900;
              extraConfig = "deny all;";
            };
          };
          extraConfig = ''
            index index.php;
            expires 1m;
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag none;
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header X-Frame-Options sameorigin;
            add_header Referrer-Policy no-referrer;
            add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
            client_max_body_size ${cfg.maxUploadSize};
            fastcgi_buffers 64 4K;
            fastcgi_hide_header X-Powered-By;
          '';
        };
      in nameValuePair cfg.hostName value);

    systemd.tmpfiles.rules = flatten (mapAttrsToList (name: cfg: [
      "d '${stateDir name}' 0750 ${user} ${group} - -"
      "d '${cfg.uploadsDir}' 0750 ${user} ${group} - -"
      "Z '${cfg.uploadsDir}' 0750 ${user} ${group} - -"
    ]) eachSite);

    systemd.services = listToAttrs (concatLists (mapAttrsToList (name: cfg: [
      (nameValuePair "wordpress-init-${name}" {
        wantedBy = [ "multi-user.target" ];
        before = [ "phpfpm-wordpress-${name}.service" ];
        after = optional cfg.database.createLocally "mysql.service";
        script = secretsScript (stateDir name);

        serviceConfig = {
          Type = "oneshot";
          User = user;
          Group = group;
        };
      })
      (nameValuePair "phpfpm-wordpress-${name}" {
        # Restart phpfpm if the wordpress package or config changes.
        restartTriggers = [ (pkg name cfg) ];
      })
    ]) eachSite));

    users.users.${user} = {
      group = group;
      isSystemUser = true;
    };

    users.groups.${group}.members = [ user config.services.nginx.user ];

  };
}
