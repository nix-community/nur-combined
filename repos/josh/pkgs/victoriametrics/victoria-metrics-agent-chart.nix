{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.44.0";
  hash = "sha256-IHsIz5VBy7fb+UvV1T3a8QR6/JgyW/499pL4qbxrcT8=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://victoria-metrics:8428"; }
    ];
  };

  meta = {
    description = "VictoriaMetrics Agent - collects metrics from various sources and stores them to VictoriaMetrics";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
