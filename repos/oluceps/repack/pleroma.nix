{ reIf, ... }:
reIf {
  services.pleroma = {
    # bcz of hard 2 use
    enable = false;
    secretConfigFile = "/run/credentials/pleroma.service/config.exs";
    configs = [
      ''
        # Pleroma instance configuration

        # NOTE: This file should not be committed to a repo or otherwise made public
        # without removing sensitive information.

        import Config

        config :pleroma, Pleroma.Web.Endpoint,
           url: [host: "nyaw.xyz", scheme: "https", port: 443],
           http: [ip: {0, 0, 0, 0}, port: 3000]

        config :pleroma, :instance,
          name: "nyaw.xyz",
          email: "pleroma@oluceps.uk",
          notify_email: "pleroma@oluceps.uk",
          limit: 5000,
          registrations_open: false

        config :pleroma, :media_proxy,
          enabled: false,
          redirect_on_failure: true
          #base_url: "https://cache.pleroma.social"

        config :pleroma, :database, rum_enabled: false
        config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
        config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"

        # Enable Strict-Transport-Security once SSL is working:
        # config :pleroma, :http_security,
        #   sts: true

        config :pleroma, configurable_from_database: true

        config :pleroma, Pleroma.Upload, filters: [Pleroma.Upload.Filter.Dedupe]
      ''
    ];
  };
}
