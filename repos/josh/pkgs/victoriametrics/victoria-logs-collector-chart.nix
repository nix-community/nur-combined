{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-collector";
  version = "0.3.7";
  hash = "sha256-Anr6TKpNkdq6Ty+DrRiOUEoUEyeCLCBbJ4aDXfKlxDs=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://victoria-logs:9428"; }
    ];
  };

  meta = {
    description = "VictoriaLogs Collector - collects logs from Kubernetes containers and stores them to VictoriaLogs";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
