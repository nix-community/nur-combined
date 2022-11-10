{
  lib,
  config,
  pkgs,
  ...
}:
# TODO: setup prometheus exporter
let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.my.services.nextcloud;
  my = config.my;
  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
  dbName = "nextcloud";
in {
  options.my.services.nextcloud = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "NextCloud";

    adminpassFile = mkOption {
      type = types.path;
      description = ''
        Path to a file containing the admin's password, must be readable by
        'nextcloud' user.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      ensureDatabases = [dbName];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "DATABASE ${dbName}" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    # not handled by module
    systemd.services.nextcloud-setup = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };

    services.postgresqlBackup = {
      databases = [dbName];
    };

    services.nextcloud = {
      enable = true;

      hostName = "cloud.${domain}";
      https = true;
      package = pkgs.nextcloud25;

      maxUploadSize = "1G";

      config = {
        overwriteProtocol = "https";

        defaultPhoneRegion = "FR";

        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbname = dbName;
        dbhost = "/run/postgresql";

        adminuser = "admin";
        adminpassFile = cfg.adminpassFile;
      };
    };

    users.groups.media.members = ["nextcloud"];

    services.nginx = {
      virtualHosts = {
        "cloud.${domain}" = {
          forceSSL = true;
          useACMEHost = fqdn;
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["cloud.${domain}"];

    my.services.restic-backup = let
      nextcloudHome = config.services.nextcloud.home;
    in
      mkIf cfg.enable {
        paths = [nextcloudHome];
        exclude = [
          # borg can fail if *.part files disappear during backup
          "${nextcloudHome}/data/*/uploads"
          # image previews can take up a lot of space
          "${nextcloudHome}/data/appdata_*/preview"
          # specific account for huge files I don't care about losing
          "${nextcloudHome}/data/misc"
        ];
      };
  };
}
