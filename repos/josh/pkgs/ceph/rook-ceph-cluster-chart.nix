{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph-cluster";
  version = "1.20.4";
  hash = "sha256-QHKHCMRmNFY+J1/0IkImGVTUzXt87yRPOzQ6ZDGddeU=";

  meta = {
    description = "Manages a single Ceph cluster namespace for Rook";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
