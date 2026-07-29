{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://piraeus.io/helm-charts/";
  chart = "snapshot-controller";
  version = "5.2.0";
  hash = "sha256-NroA88bqURpS2/Hk5iX0uVOJAdYY8zDa8ZDN8o2epPs=";

  meta = {
    description = "Deploys a Snapshot Controller in a cluster. Snapshot Controllers are often bundled with the Kubernetes distribution, this chart is meant for cases where it is not";
    homepage = "https://github.com/piraeusdatastore/helm-charts";
    license = lib.licenses.asl20;
  };
}
