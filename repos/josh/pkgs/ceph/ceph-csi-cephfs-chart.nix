{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://ceph.github.io/csi-charts";
  chart = "ceph-csi-cephfs";
  version = "3.17.0";
  hash = "sha256-5Yuy7nMc/b+XfPWI5OHpxt7n6mVd2g/1aANSWr4riW0=";

  meta = {
    description = "Container Storage Interface (CSI) driver, provisioner, snapshotter, resizer and attacher for Ceph cephfs";
    homepage = "https://github.com/ceph/ceph-csi";
    license = lib.licenses.asl20;
  };
}
