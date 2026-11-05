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
  version = "0-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "b07d8a90d8fadd112e9ac841b777ee863cda850b";
    hash = "sha256-MVy/Ul0xvC15rPTsQ69OYFRnMURTlG2+kOq3vVeXDz4=";
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
