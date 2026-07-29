{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ceph-mgr-endpoint-controller-chart";
  inherit (nur.repos.josh.ceph-mgr-endpoint-controller) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/ceph-mgr-endpoint-controller/* $out/
  '';

  passthru.tests = {
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
    description = "A Helm chart for ceph-mgr-endpoint-controller";
    homepage = "https://github.com/josh/ceph-mgr-endpoint-controller/tree/main/charts/ceph-mgr-endpoint-controller";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
