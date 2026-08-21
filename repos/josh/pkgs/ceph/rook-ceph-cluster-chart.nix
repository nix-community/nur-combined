{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph-cluster";
  version = "1.20.6";
  hash = "sha256-ZpXwHpZwMdyPG0/qMinT93iPlYS9BV758Uxr6+wxalo=";

  meta = {
    description = "Manages a single Ceph cluster namespace for Rook";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
