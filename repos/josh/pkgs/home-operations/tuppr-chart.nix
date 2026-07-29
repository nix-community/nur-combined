{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/home-operations/charts/tuppr";
  chart = "tuppr";
  version = "0.4.1";
  hash = "sha256-DfKau72uz2kdrEWpXI32vhXCrza5WDRV0qm5x0G04mU=";

  meta = {
    description = "A Helm chart for tuppr - Talos Linux Upgrade Controller";
    homepage = "https://github.com/home-operations/tuppr";
    license = lib.licenses.agpl3Only;
  };
}
