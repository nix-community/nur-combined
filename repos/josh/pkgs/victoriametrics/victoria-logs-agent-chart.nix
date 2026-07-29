{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-agent";
  version = "0.2.9";
  hash = "sha256-N3FNwaB57q6VOrbvYjzrg+26Mq2xrSP5bQvbvaOY+v4=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428/insert/jsonline"; }
    ];
  };

  meta = {
    description = "VictoriaLogs Agent - accepts logs from various protocols and replicates them across multiple VictoriaLogs instances";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
