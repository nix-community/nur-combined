{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-operator";
  version = "0.67.3";
  hash = "sha256-joucEtNUkuelf+GV1q1ICsWfiDAFYeIQAH5UgtfUgac=";
  helmTestValues = {
    admissionWebhooks.certManager.enabled = true;
  };

  meta = {
    description = "Helm chart for the VictoriaMetrics operator";
    homepage = "https://github.com/VictoriaMetrics/operator";
    license = lib.licenses.asl20;
  };
}
