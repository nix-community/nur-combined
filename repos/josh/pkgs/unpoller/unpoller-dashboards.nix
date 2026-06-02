{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "unpoller-dashboards";
  version = "0-unstable-2026-01-25";

  src = fetchFromGitHub {
    owner = "unpoller";
    repo = "dashboards";
    rev = "0fe7c05d1bf4326b217688316601324d0890493b";
    hash = "sha256-XLhmOoeTBhKxYs8tLeWy3ng7rLzaCjt0Dhn7pAuL0Vk=";
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
