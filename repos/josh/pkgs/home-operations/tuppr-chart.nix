{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/home-operations/charts/tuppr";
  chart = "tuppr";
  version = "0.5.5";
  hash = "sha256-aBN8eN1Wq+JZhEMiP4Lh2b500PalN8XKgw6EDVgmAzs=";

  meta = {
    description = "Helm chart for the Talos Linux upgrade controller";
    homepage = "https://github.com/home-operations/tuppr";
    license = lib.licenses.agpl3Only;
  };
}
