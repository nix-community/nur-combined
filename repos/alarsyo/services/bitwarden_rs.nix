{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.bitwarden_rs;
  my = config.my;

  domain = config.networking.domain;
in {
  options.my.services.bitwarden_rs = {
    enable = mkEnableOption "Bitwarden";

    privatePort = mkOption {
      type = types.port;
      default = 8081;
      example = 8081;
      description = "Port used internally for rocket server";
    };

    websocketPort = mkOption {
      type = types.port;
      default = 3012;
      example = 3012;
      description = "Port used for websocket connections";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      initialScript = pkgs.writeText "bitwarden_rs-init.sql" ''
          CREATE ROLE "bitwarden_rs" WITH LOGIN;
          CREATE DATABASE "bitwarden_rs" WITH OWNER "bitwarden_rs";
        '';
    };

    services.postgresqlBackup = {
      databases = [ "bitwarden_rs" ];
    };

    services.bitwarden_rs = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        TZ = "Europe/Paris";
        WEB_VAULT_ENABLED = true;
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_ADDRESS = "127.0.0.1";
        WEBSOCKET_PORT = cfg.websocketPort;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.privatePort;
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = false;
        DOMAIN = "https://pass.${domain}";
        DATABASE_URL = "postgresql://bitwarden_rs@/bitwarden_rs";
      };
    };

    services.nginx = {
      virtualHosts = {
        "pass.${domain}" = {
          forceSSL = true;
          useACMEHost = domain;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.privatePort}";
            proxyWebsockets = true;
          };
          locations."/notifications/hub" = {
            proxyPass = "http://127.0.0.1:${toString cfg.websocketPort}";
            proxyWebsockets = true;
          };
          locations."/notifications/hub/negotiate" = {
            proxyPass = "http://127.0.0.1:${toString cfg.privatePort}";
            proxyWebsockets = true;
          };
        };
      };
    };

    # needed for bitwarden to find files to serve for the vault
    environment.systemPackages = with pkgs; [
      bitwarden_rs-vault
    ];

    my.services.borg-backup = mkIf cfg.enable {
      paths = [ "/var/lib/bitwarden_rs" ];
      exclude = [ "/var/lib/bitwarden_rs/icon_cache" ];
    };

    services.fail2ban.jails = {
      bitwarden_rs = ''
        enabled = true
        filter = bitwarden_rs
        port = http,https
        maxretry = 5
      '';

      # Admin page isn't enabled by default, but just in case...
      bitwarden_rs-admin = ''
        enabled = true
        filter = bitwarden_rs-admin
        port = http,https
        maxretry = 2
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/bitwarden_rs.conf".text = ''
        [Definition]
        failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=bitwarden_rs.service
      '';

      "fail2ban/filter.d/bitwarden_rs-admin.conf".text = ''
        [Definition]
        failregex = ^.*Invalid admin token\. IP: <ADDR>.*$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=bitwarden_rs.service
      '';
    };
  };

}
