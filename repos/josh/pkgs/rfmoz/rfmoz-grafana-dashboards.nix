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
  version = "0-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "3827b0ad3f69a01266f4127e429160ce01d71ffd";
    hash = "sha256-GXX6kUp2B3y1CenVKmp7SAZN3tAk5ISWC+18CZ1mQvI=";
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
