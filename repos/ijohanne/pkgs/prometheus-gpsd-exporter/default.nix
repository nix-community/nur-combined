{ sources, pkgs, stdenv, ... }:
let
  python = pkgs.python3.withPackages (ps: [
    ps.prometheus-client
    (ps.toPythonModule pkgs.gpsd)
  ]);
in
stdenv.mkDerivation {
  pname = "prometheus-gpsd-exporter";
  version = "1.1.19";
  src = sources.gpsd-prometheus-exporter;
  buildInputs = [ python ];
  installPhase = ''
    mkdir -p $out/bin $out/share/prometheus-gpsd-exporter
    cp gpsd_exporter.py $out/bin/gpsd-prometheus-exporter
    chmod +x $out/bin/gpsd-prometheus-exporter
    substituteInPlace $out/bin/gpsd-prometheus-exporter \
      --replace-fail "#!/usr/bin/env python3" "#!${python}/bin/python3"
    cp gpsd_grafana_dashboard.json $out/share/prometheus-gpsd-exporter/
  '';
  meta = with pkgs.lib; {
    description = "Prometheus exporter for gpsd GPS daemon metrics";
    homepage = "https://github.com/brendanbank/gpsd-prometheus-exporter";
    license = licenses.bsd3;
  };
}
