{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph";
  version = "1.20.4";
  hash = "sha256-qPviqBSVsT7StoB56Z+ash5Lgi6z75zYqA8n0zWpcQI=";

  meta = {
    description = "Helm chart for the Rook operator, orchestrating Ceph storage on Kubernetes";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
