{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/home-operations/charts/tuppr";
  chart = "tuppr";
  version = "0.5.4";
  hash = "sha256-VYHvUcq6ac+cX02OsBB4AqoEC/AOVOiBxmynX5WaMtU=";

  meta = {
    description = "Helm chart for the Talos Linux upgrade controller";
    homepage = "https://github.com/home-operations/tuppr";
    license = lib.licenses.agpl3Only;
  };
}
