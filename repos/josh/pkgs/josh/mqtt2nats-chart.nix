{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mqtt2nats-chart";
  inherit (nur.repos.josh.mqtt2nats) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/mqtt2nats/* $out/
  '';

  passthru.tests = {
    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "mqtt2nats";
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "Helm chart for the MQTT to NATS bridge";
    homepage = "https://github.com/josh/mqtt2nats/tree/main/charts/mqtt2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
