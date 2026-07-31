{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-operator";
  version = "0.67.1";
  hash = "sha256-6lkcIuSc9t1XqehuIoMeAhP3duVd6OR4euuGMYdjm7M=";
  helmTestValues = {
    admissionWebhooks.certManager.enabled = true;
  };

  meta = {
    description = "Helm chart for the VictoriaMetrics operator";
    homepage = "https://github.com/VictoriaMetrics/operator";
    license = lib.licenses.asl20;
  };
}
