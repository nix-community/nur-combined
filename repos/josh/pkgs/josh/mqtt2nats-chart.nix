{
  lib,
  stdenvNoCC,
  nur,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mqtt2nats-chart";
  inherit (nur.repos.josh.mqtt2nats) version src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/mqtt2nats/. $out/
  '';

  passthru.tests = {
    files =
      runCommand "test-mqtt2nats-chart-files"
        {
          __structuredAttrs = true;
        }
        ''
          diff -r ${finalAttrs.src}/charts/mqtt2nats ${finalAttrs.finalPackage}
          touch $out
        '';

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
