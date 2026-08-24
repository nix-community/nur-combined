{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "prometheus-restic-exporter-chart";
  inherit (nur.repos.josh.prometheus-restic-exporter) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/restic-exporter/. $out/
  '';

  passthru.tests = {
    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "restic-exporter";
      helmValues = {
        restic.repository = "s3:https://s3.example.com/restic";
      };
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "Helm chart for the Prometheus Restic exporter";
    homepage = "https://github.com/josh/restic-exporter/tree/main/charts/restic-exporter";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
