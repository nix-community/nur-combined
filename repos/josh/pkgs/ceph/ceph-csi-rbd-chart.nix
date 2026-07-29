{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://ceph.github.io/csi-charts";
  chart = "ceph-csi-rbd";
  version = "3.17.0";
  hash = "sha256-gm90UdEiGS3lWPYlaZfvguouT6XB1NXErbLX+RoLuFc=";

  meta = {
    description = "Container Storage Interface (CSI) driver, provisioner, snapshotter, resizer and attacher for Ceph RBD";
    homepage = "https://github.com/ceph/ceph-csi";
    license = lib.licenses.asl20;
  };
}
