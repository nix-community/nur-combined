{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rfmoz-grafana-dashboards";
  version = "0-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "8b2b6e2b8b9ad6e146e2f2eeb303e9d04d0f815e";
    hash = "sha256-oPU+rC1/D1KxWxVqoruTep0M8wdl/lE+bi2dGcbP9q8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./prometheus/*.json $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    json = runCommand "test-rfmoz-grafana-dashboards-json" { nativeBuildInputs = [ jq ]; } ''
      readarray -t files < <(find ${finalAttrs.finalPackage} -name '*.json')
      [ "''${#files[@]}" -gt 0 ]
      jq --exit-status . "''${files[@]}" >/dev/null
      touch $out
    '';
  };

  meta = {
    description = "Grafana dashboards for Node Exporter and other Prometheus exporters";
    homepage = "https://github.com/rfmoz/grafana-dashboards";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
