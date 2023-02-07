{
  services.grafana = {
    protocol = "http";
    # protocol = "https";
    port = 3000;
    enable = true;
    domain = "localhost";
    # domain = "grafana.rovacsek.com";
    addr = "127.0.0.1";
    analytics.reporting.enable = false;
  };
}
