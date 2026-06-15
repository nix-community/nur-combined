{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "unpoller-dashboards";
  version = "0-unstable-2026-06-15";

  src = fetchFromGitHub {
    owner = "unpoller";
    repo = "dashboards";
    rev = "d79ef7ef30129a2ba9a60141e339a93d4bcc1bec";
    hash = "sha256-O3xAHqHiqqiQQyIkV+XK89T6Sk4GhaRpzb46SSA0ZI4=";
  };

  outputs = [
    "out"
    "influxdb"
    "prometheus"
  ];

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
    substituteInPlace $influxdb/*.json --replace-warn ' - InfluxDB' ""

    mkdir $prometheus
    for src in ./v2.0.0/*Prometheus.json; do
      basename=$(basename "$src")
      dst=''${basename/ - Prometheus/}
      cp "$src" "$prometheus/$dst"
    done
    substituteInPlace $prometheus/*.json --replace-warn ' - Prometheus' ""

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "UniFi Poller Grafana Dashboards";
    homepage = "https://github.com/unpoller/dashboards";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
