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
  version = "0-unstable-2026-10-01";

  outputs = [
    "out"
    "influxdb"
    "prometheus"
  ];

  src = fetchFromGitHub {
    owner = "unpoller";
    repo = "dashboards";
    rev = "adbe342f09d0fe06b1cc152d28ab0bae5ee3d8b9";
    hash = "sha256-K4bVK6p1B1BSQpvygg0+9uZv6wiVpfgRkBldEBUKe9Y=";
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
    json =
      runCommand "test-unpoller-dashboards-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
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
