{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://helm.goharbor.io/";
  chart = "harbor";
  version = "1.19.1";
  hash = "sha256-EyzxTVfMZsLIC8KPBdT8AHtR8pVe3DkJ5I4btlTnsnE=";

  meta = {
    description = "Helm chart for Harbor, a cloud native registry that stores, signs, and scans content";
    homepage = "https://goharbor.io";
    license = lib.licenses.asl20;
  };
}
