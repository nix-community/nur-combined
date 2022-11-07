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

  cfg = config.my.services.pleroma;
  my = config.my;

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.pleroma = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Pleroma";

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "Pleroma server port";
    };

    secretConfigFile = mkOption {
      type = types.str;
      default = "/var/lib/pleroma/secrets.exs";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pleroma = {
      path = [
        pkgs.hexdump
        pkgs.exiftool
      ];
    };

    services.pleroma = {
      enable = true;
      secretConfigFile = cfg.secretConfigFile;

      configs = [
        ''
          import Config

          config :pleroma, Pleroma.Web.Endpoint,
             url: [host: "social.${domain}", scheme: "https", port: 443],
             http: [ip: {127, 0, 0, 1}, port: ${toString cfg.port}]

          config :pleroma, :instance,
            name: "social.alarsyo.net",
            email: "contact+pleroma@alarsyo.net",
            notify_email: "pleroma@alarsyo.net",
            limit: 5000,
            registrations_open: false

          config :pleroma, :media_proxy,
            enabled: false,
            redirect_on_failure: true
            #base_url: "https://cache.pleroma.social"

          config :pleroma, Pleroma.Repo,
            adapter: Ecto.Adapters.Postgres,
            username: "pleroma",
            database: "pleroma",
            hostname: "localhost"

          # Configure web push notifications
          config :web_push_encryption, :vapid_details,
            subject: "mailto:contact+pleroma@alarsyo.net"

          config :pleroma, :database, rum_enabled: false
          config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
          config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"

          # Enable Strict-Transport-Security once SSL is working:
          # config :pleroma, :http_security,
          #   sts: true

          config :pleroma, configurable_from_database: false

          config :pleroma, Pleroma.Upload, filters: [Pleroma.Upload.Filter.AnonymizeFilename]
        ''
      ];
    };

    services.nginx.virtualHosts."social.${domain}" = {
      forceSSL = true;
      useACMEHost = fqdn;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        proxyWebsockets = true;
        extraConfig = ''
          etag on;
          client_max_body_size 50m;
        '';
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["social.${domain}"];
  };
}
