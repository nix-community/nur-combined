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

  cfg = config.my.services.vaultwarden;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.vaultwarden = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Vaultwarden";

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
    };

    services.postgresqlBackup = {
      databases = ["vaultwarden"];
    };

    services.vaultwarden = {
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
        # FIXME: should be renamed to vaultwarden eventually
        DATABASE_URL = "postgresql://vaultwarden@/vaultwarden";
      };
    };

    services.nginx = {
      virtualHosts = {
        "pass.${domain}" = {
          forceSSL = true;
          useACMEHost = fqdn;

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

    security.acme.certs.${fqdn}.extraDomainNames = ["pass.${domain}"];

    # FIXME: should be renamed to vaultwarden eventually
    my.services.restic-backup = mkIf cfg.enable {
      paths = ["/var/lib/bitwarden_rs"];
      exclude = ["/var/lib/bitwarden_rs/icon_cache"];
    };

    services.fail2ban.jails = {
      vaultwarden = ''
        enabled = true
        filter = vaultwarden
        port = http,https
        maxretry = 5
      '';

      # Admin page isn't enabled by default, but just in case...
      vaultwarden-admin = ''
        enabled = true
        filter = vaultwarden-admin
        port = http,https
        maxretry = 2
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/vaultwarden.conf".text = ''
        [Definition]
        failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=vaultwarden.service
      '';

      "fail2ban/filter.d/vaultwarden-admin.conf".text = ''
        [Definition]
        failregex = ^.*Invalid admin token\. IP: <ADDR>.*$
        ignoreregex =
        journalmatch = _SYSTEMD_UNIT=vaultwarden.service
      '';
    };
  };
}
