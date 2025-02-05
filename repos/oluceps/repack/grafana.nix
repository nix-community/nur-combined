{ reIf, config, ... }:
reIf {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "::";
        http_port = 3002;
        domain = config.networking.fqdn;
        root_url = "https://${config.networking.fqdn}/grafana";
        serve_from_sub_path = true;
      };
    };
  };
}
