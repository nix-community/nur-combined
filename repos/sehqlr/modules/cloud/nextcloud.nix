{ config, pkgs, ... }: {  
  services.nextcloud = {
    enable = true;
    package = pkgs.nexcloud20;
    hostName = "nextcloud.samhatfield.me";
    https = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      adminpassFile = "/srv/secrets/nextcloud-admin-password.txt";
      adminuser = "root";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }];
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
