{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "unpoller-dashboards";
  version = "0-unstable-2026-11-07";

  outputs = [
    "out"
    "influxdb"
    "prometheus"
  ];

  src = fetchFromGitHub {
    owner = "unpoller";
    repo = "dashboards";
    rev = "1c979584361caa6dcb99432352be2fe902f036d2";
    hash = "sha256-RnHKG4wzLz5Vg673YjEoq3rRCFyvd35TmDyL9c5Or8Y=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -R ./v2.0.0/*.json $out/

    mkdir $influxdb
    for src in ./v2.0.0/*InfluxDB.json; do
      basename=$(basename "$src")
      dst=''${basename/ - InfluxDB/}
      cp "$src" "$influxdb/$dst"
    done
    substituteInPlace $influxdb/*.json --replace-fail ' - InfluxDB' ""

    mkdir $prometheus
    for src in ./v2.0.0/*Prometheus.json; do
      basename=$(basename "$src")
      dst=''${basename/ - Prometheus/}
      cp "$src" "$prometheus/$dst"
    done
    substituteInPlace $prometheus/*.json --replace-fail ' - Prometheus' ""

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    json = runCommand "test-unpoller-dashboards-json" { nativeBuildInputs = [ jq ]; } ''
      readarray -t files < <(find ${finalAttrs.finalPackage} ${finalAttrs.finalPackage.influxdb} ${finalAttrs.finalPackage.prometheus} -name '*.json')
      [ "''${#files[@]}" -gt 0 ]
      jq --exit-status . "''${files[@]}" >/dev/null
      touch $out
    '';
  };

  meta = {
    description = "Grafana dashboards for UniFi Poller metrics";
    homepage = "https://github.com/unpoller/dashboards";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
