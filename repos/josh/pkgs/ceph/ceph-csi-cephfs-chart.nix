{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://ceph.github.io/csi-charts";
  chart = "ceph-csi-cephfs";
  version = "3.17.1";
  hash = "sha256-iCSXKGBN9bXkm/EfA1CChd/eYjgtYH+yIB1xCjnZHus=";

  meta = {
    description = "Container Storage Interface (CSI) driver, provisioner, snapshotter, resizer and attacher for Ceph cephfs";
    homepage = "https://github.com/ceph/ceph-csi";
    license = lib.licenses.asl20;
  };
}
