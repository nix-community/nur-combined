{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://piraeus.io/helm-charts/";
  chart = "snapshot-controller";
  version = "5.2.0";
  hash = "sha256-NroA88bqURpS2/Hk5iX0uVOJAdYY8zDa8ZDN8o2epPs=";

  meta = {
    description = "Helm chart deploying a CSI snapshot controller for distributions that do not bundle one";
    homepage = "https://github.com/piraeusdatastore/helm-charts";
    license = lib.licenses.asl20;
  };
}
