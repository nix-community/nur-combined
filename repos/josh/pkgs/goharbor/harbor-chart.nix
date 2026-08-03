{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://helm.goharbor.io/";
  chart = "harbor";
  version = "1.19.2";
  hash = "sha256-otgAUxUlx9iSCfGj9hcyZaAsBwx6fz9iZcEzyWX2jRU=";

  meta = {
    description = "Helm chart for Harbor, a cloud native registry that stores, signs, and scans content";
    homepage = "https://goharbor.io";
    license = lib.licenses.asl20;
  };
}
