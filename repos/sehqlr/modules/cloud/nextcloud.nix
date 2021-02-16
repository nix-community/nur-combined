{ config, pkgs, ... }: {
  security.acme.certs."nextcloud.samhatfield.me".email = "hey@samhatfield.me";
  services.nginx.virtualHosts."nextcloud.samhatfield.me" = {
    forceSSL = true;
    enableACME = true;
  };
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud20;
    hostName = "nextcloud.samhatfield.me";
    https = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      adminpassFile = "/srv/secrets/nextcloud-admin-password.txt";
      adminuser = "admin";
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
