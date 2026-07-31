{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "prometheus-node-exporter";
  version = "4.56.1";
  hash = "sha256-YHBjSqtecnVYJ8IXZQZaNWSFudLfvLkIRdCRBpV6leQ=";

  meta = {
    description = "Helm chart for the Prometheus node exporter, exposing hardware and OS metrics";
    homepage = "https://github.com/prometheus/node_exporter";
    license = lib.licenses.asl20;
  };
}
