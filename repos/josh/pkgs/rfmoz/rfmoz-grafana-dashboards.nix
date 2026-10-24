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
  version = "0-unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "a741a41aeb5d3fb6dc414a72613213d812ec6a1a";
    hash = "sha256-QNUQSTt3+AeQ8kPxym4zL7v4WbzqM8sFXF6P2/5AJu0=";
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
