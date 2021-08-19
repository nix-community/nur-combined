# A self-hosted cloud.
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nextcloud;
  domain = config.networking.domain;
  nextcloudDomain = "nextcloud.${config.networking.domain}";
in
{
  options.my.services.nextcloud = with lib; {
    enable = mkEnableOption "Nextcloud";
    maxSize = mkOption {
      type = types.str;
      default = "512M";
      example = "1G";
      description = "Maximum file upload size";
    };
    admin = mkOption {
      type = types.str;
      default = "Ambroisie";
      example = "admin";
      description = "Name of the admin user";
    };
    password = mkOption {
      type = types.str;
      example = "password";
      description = "The admin user's password";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud22;
      hostName = nextcloudDomain;
      home = "/var/lib/nextcloud";
      maxUploadSize = cfg.maxSize;
      config = {
        adminuser = cfg.admin;
        adminpass = cfg.password; # Insecure, but I don't care
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        overwriteProtocol = "https"; # Nginx only allows SSL
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
        }
      ];
    };

    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };

    services.nginx.virtualHosts."${nextcloudDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/".proxyPass = "http://127.0.0.1:3000/";
    };

    my.services.backup = {
      paths = [
        config.services.nextcloud.home
      ];
      exclude = [
        # image previews can take up a lot of space
        "${config.services.nextcloud.home}/data/appdata_*/preview"
      ];
    };
  };
}
