{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "prometheus-blackbox-exporter";
  version = "11.16.0";
  hash = "sha256-bmlBYswvzBjLj2+Tl8DSXjjmjvP2zTHk9TOOH84Uc2c=";

  meta = {
    description = "Prometheus Blackbox Exporter";
    homepage = "https://github.com/prometheus/blackbox_exporter";
    license = lib.licenses.asl20;
  };
}
