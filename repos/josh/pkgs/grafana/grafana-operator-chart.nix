{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/grafana/helm-charts/grafana-operator";
  chart = "grafana-operator";
  version = "5.24.0";
  hash = "sha256-jULnmFaxi3gsWbCnE26FfML6MOqQ60QCpMuOoSv0hdw=";

  meta = {
    description = "Helm chart for the Grafana Operator";
    homepage = "https://github.com/grafana/grafana-operator";
    license = lib.licenses.asl20;
  };
}
