{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jmap2nats-chart";
  inherit (nur.repos.josh.jmap2nats) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/jmap2nats/* $out/
  '';

  passthru.tests = {
    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "jmap2nats";
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "A Helm chart for jmap2nats";
    homepage = "https://github.com/josh/jmap2nats/tree/main/charts/jmap2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
