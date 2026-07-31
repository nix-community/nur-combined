{
  lib,
  stdenvNoCC,
  nur,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ceph-mgr-endpoint-controller-chart";
  inherit (nur.repos.josh.ceph-mgr-endpoint-controller) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/ceph-mgr-endpoint-controller/. $out/
  '';

  passthru.tests = {
    files =
      runCommand "test-ceph-mgr-endpoint-controller-chart-files"
        {
          __structuredAttrs = true;
        }
        ''
          diff -r ${finalAttrs.src}/charts/ceph-mgr-endpoint-controller ${finalAttrs.finalPackage}
          touch $out
        '';

    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "ceph-mgr-endpoint-controller";
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "Helm chart for the Ceph manager endpoint controller";
    homepage = "https://github.com/josh/ceph-mgr-endpoint-controller/tree/main/charts/ceph-mgr-endpoint-controller";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
