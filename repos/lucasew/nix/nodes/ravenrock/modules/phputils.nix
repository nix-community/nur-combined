{pkgs, lib, config, options, ...}:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.services.php-utils;
in {
  options.services.php-utils = {
    enable = mkEnableOption "php-utils";
    user = mkOption {
      type = types.str;
      default = "php-utils";
      description = "Which user to use to run the app, it will be created";
    };
    domain = mkOption {
      type = types.str;
      description = "nginx virtual host to use";
      default = "utils." + config.vps.domain;
    };
  };
  config = mkIf cfg.enable {
    users = {
      users."${cfg.user}" = {
        isSystemUser = true;
        createHome = true;
        home = "/srv/php-utils/data";
        group = cfg.user;
        extraGroups = [
          "docker"
        ];
      };
      groups."${cfg.user}" = {};
    };
    services.phpfpm.pools.utils = { # From https://nixos.wiki/wiki/Nginx
      inherit (cfg) user;
      settings = {
        pm = "dynamic";
        "listen.owner" = config.services.nginx.user;
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
        "pm.max_requests" = 500;
      };
      phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
    };
    services.nginx.virtualHosts."${cfg.domain}" = {
      root = "/srv/php-utils/code";
      locations."~ \\.php$".extraConfig = ''
        fastcgi_pass unix:${config.services.phpfpm.pools.utils.socket};
        fastcgi_index index.php;
      '';
    };
  };
}
