{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/home-operations/charts/tuppr";
  chart = "tuppr";
  version = "0.4.3";
  hash = "sha256-aZGnFVHmpY9k9v/iadeKAn/GIv4pDOGJdznzHbU26CQ=";

  meta = {
    description = "Helm chart for the Talos Linux upgrade controller";
    homepage = "https://github.com/home-operations/tuppr";
    license = lib.licenses.agpl3Only;
  };
}
