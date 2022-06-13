{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.my.services.miniflux;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.miniflux = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Serve a Miniflux instance";

    adminCredentialsFile = mkOption {
      type = types.str;
      default = null;
      example = "./secrets/miniflux-admin-credentials";
      description = "File containing ADMIN_USERNAME= and ADMIN_PASSWORD=";
    };

    privatePort = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Port to serve the app";
    };
  };

  config = mkIf cfg.enable {
    # services.postgresql is automatically enabled by services.miniflux, let's
    # back it up
    services.postgresqlBackup = {
      databases = ["miniflux"];
    };

    services.miniflux = {
      enable = true;
      adminCredentialsFile = cfg.adminCredentialsFile;
      # TODO: setup metrics collection
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString cfg.privatePort}";
        BASE_URL = "https://reader.${domain}/";

        CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
        CLEANUP_ARCHIVE_READ_DAYS = "-1";
      };
    };

    services.nginx = {
      virtualHosts = {
        "reader.${domain}" = {
          forceSSL = true;
          useACMEHost = fqdn;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.privatePort}";
          };
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["reader.${domain}"];
  };
}
