{ config, lib, ... }:
{
  vacu.databases.nextcloud = {
    user = "ncadmin";
    fromContainer = "vacustore";
  };

  vacu.proxiedServices.vacustore = {
    domain = "vacu.store";
    fromContainer = "vacustore";
    port = 80;
    forwardFor = true;
    maxConnections = 100;
  };

  systemd.services."container@vacustore".serviceConfig.TimeoutStartSec = lib.mkForce "infinity";

  containers.vacustore = {
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";

    autoStart = false;
    ephemeral = false;

    bindMounts."/ncdata" = {
      hostPath = "/trip/ncdata";
      isReadOnly = false;
    };

    # bindMounts."${config.sops.secrets.vacustore.path}" = { isReadOnly = true; };

    config =
      let
        outer_config = config;
      in
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        system.stateVersion = "22.05";

        networking.firewall.enable = false;
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;

        services.nginx.virtualHosts."vacu.store".extraConfig = ''
          client_body_timeout 5m;
        '';

        environment.systemPackages = [ config.services.nextcloud.package ]; # make occ command available without having to dig for it

        systemd.services.nextcloud-setup.serviceConfig.TimeoutStartSec = "infinity";

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud31;
          configureRedis = true;
          hostName = "vacu.store";
          datadir = "/ncdata";
          https = true;
          maxUploadSize = "1000G";
          database.createLocally = false;

          extraApps = {
            inherit (config.services.nextcloud.package.packages.apps)
              calendar
              notes
              tasks
              contacts
              # gpoddersync
              richdocuments
              ;
          };

          phpOptions."opcache.interned_strings_buffer" = "32";

          config = {
            adminpassFile = "/etc/admin_password";
            dbtype = "pgsql";
            dbuser = "ncadmin";
            dbhost = outer_config.containers.vacustore.hostAddress;
            dbname = "nextcloud";
          };

          settings = {
            loglevel = 1;
            default_phone_region = "US";
            overwriteprotocol = "https";
            trusted_proxies = [ outer_config.containers.vacustore.hostAddress ];
            allow_user_to_change_display_name = false;
            lost_password_link = "disabled";
          };

          secretFile = "/etc/nc-secrets.json";
        };

        # services.collabora-online = {
        #   enable = true;
        #   settings = {
        #     logging.level = "trace";
        #     ssl.enable = false;
        #     ssl.termination = false;
        #   };
        # };
      };
  };
}
