{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://jellyfin.github.io/jellyfin-helm";
  chart = "jellyfin";
  version = "3.2.0";
  hash = "sha256-d19vMsz+y8V0OGxL4BxK/Twh8JEUIWtypJ/vRF/Flu8=";

  meta = {
    description = "Helm chart for Jellyfin, the free software media system";
    homepage = "https://jellyfin.org";
    license = lib.licenses.gpl2Only;
  };
}
