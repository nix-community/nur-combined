{
  reIf,
  config,
  ...
}:
reIf {
  services = {
    grafana = {
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
      };
    };
  };
  systemd.services.grafana.serviceConfig = {
    EnvironmentFile = config.vaultix.secrets.grafana.path;
  };
}
