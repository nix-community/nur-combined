{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph";
  version = "1.20.5";
  hash = "sha256-V3SCQ/7fWCZaeqmab+rsdKEFJWz/L7M2roIViflDG8k=";

  meta = {
    description = "Helm chart for the Rook operator, orchestrating Ceph storage on Kubernetes";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
