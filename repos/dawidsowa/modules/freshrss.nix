{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.freshrss;
  poolName = "freshrss";
  package = (import ../default.nix { inherit pkgs; }).freshrss;
in
{
  options = {
    services.freshrss = {
      enable = mkEnableOption "FreshRSS";
      # TODO: Replace Sqlite with PostgreSQL

      user = mkOption {
        type = types.str;
        default = "freshrss";
        example = "freshrss";
        description = ''
          User account under which FreshRSS run.
          If it's freshrss it will be created.
        ''; # TODO Format it.
      };

      group = mkOption {
        type = types.str;
        default = "freshrss";
        example = "freshrss";
        description = ''
          Group under which the FreshRSS run.
          It will be created if it doesn't exist.
        '';
      };

      pool = mkOption {
        type = types.str;
        default = poolName;
        description = ''
          Name of existing phpfpm pool that is used to run web-application.
          If not specified a pool will be created automatically with
          default values.
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/freshrss/data";
        description = ''
          Location of FreshRSS data directory.
        '';
      };

      extensionsDir = mkOption {
        type = types.str;
        default = "/var/lib/freshrss/extensions";
        description = ''
          Location of FreshRSS extensions directory.
        '';
      };


      virtualHost = mkOption {
        type = types.nullOr types.str;
        default = "freshrss";
        description = ''
          Name of the nginx virtualhost to use and setup. If null, do not setup any virtualhost.
        '';
      };

      initialPassword = mkOption {
        type = types.str;
        example = "correcthorsebatterystaple";
        description = ''
          Specifies the initial password for the admin, i.e. the password assigned if the user does not already exist.
          The password specified here is world-readable in the Nix store, so it should be changed promptly.
        '';
      };

      interval = mkOption {
        type = types.str;
        default = "*:0/30";
        description = ''
          How often FreshRSS is updated. See systemd.time(7) for more
          information about the format.
        '';
      };

      admin = mkOption {
        type = types.str;
        default = "admin";
        example = "admin";
        description = ''
          Administrator username. It will be used to login to FreshRSS.
        '';
      };

      database = {
        type = mkOption {
          type = types.enum [ "sqlite" "pgsql" ];
          default = "sqlite";
          description = ''
            What type of database to use.
          ''; # TODO What to do when this option changes.
        };

        createLocally = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Create the database and database user locally.
            Has no effect if database.type is sqlite.
          ''; # TODO Format
        };

        name = mkOption {
          type = types.str;
          default = "freshrss";
          description = ''
            Name of the database.
            Has no effect if database.type is sqlite.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "freshrss";
          description = ''
            The database user.
            Has no effect if database.type is sqlite.
          '';
        };

      };
    };
  };

  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.user == "freshrss") {
      freshrss = {
        description = "FreshRSS user";
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups.${cfg.group} = { };


    services.phpfpm.pools = mkIf (cfg.pool == poolName) {
      ${poolName} = {
        user = cfg.user;
        settings = mapAttrs (name: mkDefault) {
          "listen.owner" = config.services.nginx.user;
          "listen.group" = config.services.nginx.group;
          "listen.mode" = "0600";
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.start_servers" = 10;
          "pm.min_spare_servers" = 5;
          "pm.max_spare_servers" = 20;
          "pm.max_requests" = 500;
          "catch_workers_output" = 1;
        };
      };
    };

    services.nginx = mkIf (cfg.virtualHost != null) {
      enable = true;
      virtualHosts = {
        ${cfg.virtualHost} = {
          root = "${package}/p";

          extraConfig = "index index.php index.html index.htm;";

          locations."/" = {
            tryFiles = "$uri $uri/ index.php";
          };

          locations."~ ^.+?.php(/.*)?$" = {
            extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi_params;
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:${config.services.phpfpm.pools.${poolName}.socket};
              set $path_info $fastcgi_path_info;
              fastcgi_param PATH_INFO $path_info;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param FRESHRSS_DATA ${cfg.dataDir};
              fastcgi_param FRESHRSS_EXTENSIONS ${cfg.extensionsDir};
            '';
          };
        };
      };
    };

    services.postgresql = mkIf (cfg.database.type == "pgsql" && cfg.database.createLocally) {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensurePermissions = { "DATABASE ${cfg.database.name}" = "ALL PRIVILEGES"; };
        }
      ];
    };

    systemd.tmpfiles.rules =
      [
        "Z '${cfg.dataDir}' - ${cfg.user} ${cfg.group} - -"
        "d '${cfg.extensionsDir}' 0750 ${cfg.user} ${cfg.group} - -"
        "Z '${cfg.extensionsDir}' - ${cfg.user} ${cfg.group} - -"
      ];

    system.activationScripts.freshrss =
      let
        host = if cfg.database.createLocally then "/var/run/postgresql" else cfg.database.host;
        databaseSetup = {
          sqlite = "--db-type sqlite";
          pgsql = "--db-type pgsql --db-host ${host} --db-base ${cfg.database.name}";
        }.${cfg.database.type};
      in
      ''
        export FRESHRSS_DATA="${cfg.dataDir}"
        mkdir -p ${cfg.dataDir}
        cp -r --no-preserve=mode,ownership ${package}/data/* ${cfg.dataDir}
        chown ${cfg.user}:${cfg.group} -R ${cfg.dataDir}

        if [ ! -f ${cfg.dataDir}/config.php ]; then
          ${pkgs.sudo}/bin/sudo -Eu freshrss ${pkgs.php}/bin/php ${package}/cli/do-install.php --default_user ${cfg.admin} ${databaseSetup} --disable_update
          ${pkgs.sudo}/bin/sudo -Eu freshrss ${pkgs.php}/bin/php ${package}/cli/create-user.php --user ${cfg.admin} --password '${cfg.initialPassword}'
        fi

        rm -f ${cfg.dataDir}/do-install.txt 
      '';

    systemd = {
      services.freshrss-update = {
        environment.FRESHRSS_DATA = cfg.dataDir;
        startAt = cfg.interval;
        serviceConfig = {
          ExecStart =
            "${pkgs.php}/bin/php ${package}/app/actualize_script.php";
          User = cfg.user;
          Group = cfg.group;
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "60";
        };
      };
    };
  };
}
