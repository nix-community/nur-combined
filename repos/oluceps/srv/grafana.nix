{ pkgs, config, ... }:
{
  enable = true;
  settings = {
    server = {
      http_addr = "0.0.0.0";
      http_port = 3002;
      domain = config.networking.fqdn;
      root_url = "https://${config.networking.fqdn}/grafana";
      serve_from_sub_path = true;
    };
  };
}
