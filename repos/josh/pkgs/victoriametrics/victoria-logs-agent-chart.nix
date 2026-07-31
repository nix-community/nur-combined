{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-agent";
  version = "0.2.9";
  hash = "sha256-N3FNwaB57q6VOrbvYjzrg+26Mq2xrSP5bQvbvaOY+v4=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://victoria-logs:9428"; }
    ];
  };

  meta = {
    description = "Helm chart for the VictoriaLogs agent, replicating logs across VictoriaLogs instances";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
