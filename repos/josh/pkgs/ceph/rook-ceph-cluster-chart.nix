{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph-cluster";
  version = "1.20.5";
  hash = "sha256-pRAJ/7bNSm4Dm0Y1PHmF/UcBaY+7+0aIeOmHI7LclEI=";

  meta = {
    description = "Manages a single Ceph cluster namespace for Rook";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
