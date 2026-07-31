{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/home-operations/charts/tuppr";
  chart = "tuppr";
  version = "0.4.4";
  hash = "sha256-5Tko4g3UMkBFES6SZdcovtoIXGuREOa1kgkmKpNvNaQ=";

  meta = {
    description = "Helm chart for the Talos Linux upgrade controller";
    homepage = "https://github.com/home-operations/tuppr";
    license = lib.licenses.agpl3Only;
  };
}
