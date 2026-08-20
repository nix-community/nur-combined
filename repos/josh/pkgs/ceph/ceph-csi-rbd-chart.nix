{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://ceph.github.io/csi-charts";
  chart = "ceph-csi-rbd";
  version = "3.17.1";
  hash = "sha256-nym+7Czbg/Vfi9/9BFWhQ9KmIBUlpmBFMdzAAASIr4w=";

  meta = {
    description = "Container Storage Interface (CSI) driver, provisioner, snapshotter, resizer and attacher for Ceph RBD";
    homepage = "https://github.com/ceph/ceph-csi";
    license = lib.licenses.asl20;
  };
}
