{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.rook.io/release/";
  chart = "rook-ceph";
  version = "1.20.3";
  hash = "sha256-5n3WIada4H/DMfJMh4IUPH5Rb47RfbqjApAwN09ckRk=";

  meta = {
    description = "File, Block, and Object Storage Services for your Cloud-Native Environment";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
  };
}
