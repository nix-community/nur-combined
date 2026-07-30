{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-operator";
  version = "0.67.0";
  hash = "sha256-2e/K2zzfn2iZf2/UV96Hezj7veI32bZg3cTTTZP2XlA=";
  helmTestValues = {
    admissionWebhooks.certManager.enabled = true;
  };

  meta = {
    description = "VictoriaMetrics Operator";
    homepage = "https://github.com/VictoriaMetrics/operator";
    license = lib.licenses.asl20;
  };
}
