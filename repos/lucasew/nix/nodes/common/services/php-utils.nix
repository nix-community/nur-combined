{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.php-utils;
in
{
  options = {
    services.php-utils = {
      enable = (lib.mkEnableOption "php utils") // {
        default = true;
      };
      webRoot = lib.mkOption {
        type = lib.types.str;
        default = "/etc/phputils";
        description = "Where is the PHP files?";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/phputils";
        description = "Home folder of service";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "phputils";
        description = "User for the service";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.phpfpm.pools.php-utils = {
      inherit (cfg) user;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "pm" = "ondemand";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
      };
      phpEnv.PATH = lib.makeBinPath [ pkgs.php ];
    };
    services.nginx.virtualHosts."php-utils.${config.networking.hostName}.${config.networking.domain}" = {
      locations = {
        "/" = {
          root = cfg.webRoot;
          extraConfig = ''
            try_files $uri $uri/index.php $uri.php;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.php-utils.socket};
            include ${config.services.nginx.package}/conf/fastcgi.conf;
          '';
        };
      };
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      createHome = true;
      home = cfg.dataDir;
      group = config.users.groups.${cfg.user}.name;
    };
    users.groups.${cfg.user} = { };

    systemd.tmpfiles.rules = [
      "d \"${cfg.webRoot}\" 755 ${cfg.user} ${cfg.user}"
      "d \"${cfg.dataDir}\" 700 ${cfg.user} ${cfg.user}"
    ];
  };
}
