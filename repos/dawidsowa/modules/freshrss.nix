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

      user = mkOption {
        type = types.str;
        default = "nginx";
        example = "nginx";
        description = ''
          User account under which FreshRSS run.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "nginx";
        example = "nginx";
        description = ''
          Group under which the FreshRSS run.
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
        default = "/var/lib/freshrss";
        description = ''
          Location in which FreshRSS directory will be created.
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
    };
  };

  config = mkIf cfg.enable {
    services.phpfpm.pools = mkIf (cfg.pool == poolName) {
      ${poolName} = {
        user = cfg.user;
        settings = mapAttrs (name: mkDefault) {
          "listen.owner" = cfg.user;
          "listen.group" = cfg.user;
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
              fastcgi_pass unix:${
                config.services.phpfpm.pools.${poolName}.socket
              };
              set $path_info $fastcgi_path_info;
              fastcgi_param PATH_INFO $path_info;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param FRESHRSS_DATA ${cfg.dataDir};
            '';
          };
        };
      };
    };

    systemd.tmpfiles.rules =
      [ "d '${cfg.dataDir}/data' 0750 ${cfg.user} ${cfg.group} - -" ];

    system.activationScripts.freshrss = ''
      export FRESHRSS_DATA="${cfg.dataDir}"
      mkdir -p ${cfg.dataDir}/data
      cp -r --no-preserve=mode,ownership ${package}/data/* ${cfg.dataDir}/data

      if [ ! -f ${cfg.dataDir}/data/config.php ]; then
        ${pkgs.php}/bin/php ${package}/cli/do-install.php --default_user admin --db-type sqlite --disable_update
        ${pkgs.php}/bin/php ${package}/cli/create-user.php --user admin --password '${cfg.initialPassword}'
      fi

      rm -f ${cfg.dataDir}/data/do-install.txt 
    '';

    systemd = {
      services.freshrss-update = {
        environment.FRESHRSS_DATA = cfg.dataDir;
        startAt = cfg.interval;
        serviceConfig = {
          ExecStart =
            "${pkgs.php}/bin/php ${package}/app/actualize_script.php";
          User = "nginx";
          Group = "nginx";
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "60";
        };
      };
    };
  };
}
