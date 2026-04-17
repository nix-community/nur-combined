{
  flake.modules.nixos.grafana =
    { config, ... }:
    {
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "fdcc::3";
            http_port = 3002;
            domain = "gf.nyaw.xyz";
            root_url = "https://gf.nyaw.xyz/";
            serve_from_sub_path = false;
          };
          auth = {
            oauth_allow_insecure_email_lookup = true;
          };
          security.secret_key = "$__file{${config.vaultix.secrets.grafana-secretkey.path}}";
        };
      };
      vaultix.secrets = {
        grafana = {
          owner = "grafana";
          mode = "400";
        };
        grafana-secretkey = {
          owner = "grafana";
          mode = "400";
        };
      };
      systemd.services.grafana.serviceConfig = {
        EnvironmentFile = config.vaultix.secrets.grafana.path;
      };
    };
}
