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
  version = "0-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "6c2de7ebaea4dd1dad7089d86d75de71417a3d0b";
    hash = "sha256-bK2pE+mtPfjJzQZzHjbayQBZF7hDLHYjtJIH70MmQuw=";
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
