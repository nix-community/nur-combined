{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph";
  version = "1.20.6";
  hash = "sha256-SJZ30Iw2oYzrL+nbOv/r5enGdPVkE8kIoUZrCOIuShw=";

  meta = {
    description = "Helm chart for the Rook operator, orchestrating Ceph storage on Kubernetes";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
