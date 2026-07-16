{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-agent";
  version = "0.2.9";
  sha256 = "sha256-N3FNwaB57q6VOrbvYjzrg+26Mq2xrSP5bQvbvaOY+v4=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428/insert/jsonline"; }
    ];
  };
}
