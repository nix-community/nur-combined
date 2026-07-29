{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-collector";
  version = "0.3.7";
  hash = "sha256-Anr6TKpNkdq6Ty+DrRiOUEoUEyeCLCBbJ4aDXfKlxDs=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428"; }
    ];
  };
}
