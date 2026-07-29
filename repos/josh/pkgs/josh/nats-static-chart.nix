{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nats-static-chart";
  inherit (nur.repos.josh.nats-static) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/nats-static/* $out/
  '';

  passthru.tests = {
    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "nats-static";
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "Helm chart for the nats-static file server";
    homepage = "https://github.com/josh/nats-static/tree/main/charts/nats-static";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
