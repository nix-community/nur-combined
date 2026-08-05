{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/home-operations/charts/tuppr";
  chart = "tuppr";
  version = "0.4.7";
  hash = "sha256-FWluYH/yGsmMPnZgYa3ANL61UUQY0Tjb4jA8xPWrw1o=";

  meta = {
    description = "Helm chart for the Talos Linux upgrade controller";
    homepage = "https://github.com/home-operations/tuppr";
    license = lib.licenses.agpl3Only;
  };
}
