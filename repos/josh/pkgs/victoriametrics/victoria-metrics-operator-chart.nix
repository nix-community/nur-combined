{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-operator";
  version = "0.67.2";
  hash = "sha256-4KMH0vjk79BiDt/k7LV5dodd1zCTMeaS8cm1IKwOYQs=";
  helmTestValues = {
    admissionWebhooks.certManager.enabled = true;
  };

  meta = {
    description = "Helm chart for the VictoriaMetrics operator";
    homepage = "https://github.com/VictoriaMetrics/operator";
    license = lib.licenses.asl20;
  };
}
