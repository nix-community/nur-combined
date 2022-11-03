# A self-hosted cloud.
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nextcloud;
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
    passwordFile = mkOption {
      type = types.str;
      example = "/var/lib/nextcloud/password.txt";
      description = ''
        Path to a file containing the admin's password, must be readable by
        'nextcloud' user.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud25;
      hostName = "nextcloud.${config.networking.domain}";
      home = "/var/lib/nextcloud";
      maxUploadSize = cfg.maxSize;
      config = {
        adminuser = cfg.admin;
        adminpassFile = cfg.passwordFile;
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

    # The service above configures the domain, no need for my wrapper
    services.nginx.virtualHosts."nextcloud.${config.networking.domain}" = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
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
