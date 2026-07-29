{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "restic-rados-server-chart";
  inherit (nur.repos.josh.restic-rados-server) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/restic-rados-server/* $out/
  '';

  passthru.tests = {
    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "restic-rados-server";
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "A Helm chart for restic-rados-server";
    homepage = "https://github.com/josh/restic-rados-server/tree/main/charts/restic-rados-server";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
