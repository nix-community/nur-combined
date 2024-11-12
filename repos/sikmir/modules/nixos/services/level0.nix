{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.level0;
in
{
  options.services.level0 = {
    enable = mkEnableOption "level0";
    package = mkPackageOption pkgs "level0" { };
    nginx = mkOption {
      default = { };
      description = ''
        Configuration for nginx reverse proxy.
      '';
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Configure the nginx reverse proxy settings.
            '';
          };
          hostName = mkOption {
            type = types.str;
            description = ''
              The hostname use to setup the virtualhost configuration
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.phpfpm.pools.level0 = {
        user = "nobody";
        settings = {
          "pm" = "dynamic";
          "listen.owner" = config.services.nginx.user;
          "pm.max_children" = 5;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 1;
          "pm.max_spare_servers" = 3;
          "pm.max_requests" = 500;
          "security.limit_extensions" = ".php .js";
        };
      };
    }
    (mkIf cfg.nginx.enable {
      services.nginx = {
        enable = true;
        virtualHosts."${cfg.nginx.hostName}" = {
          locations."/" = {
            root = "${cfg.package}/share/php/level0/www";
            extraConfig = ''
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass  unix:${config.services.phpfpm.pools.level0.socket};
              fastcgi_index index.php;
              include ${config.services.nginx.package}/conf/fastcgi.conf;
            '';
          };
        };
      };
    })
  ]);
}
