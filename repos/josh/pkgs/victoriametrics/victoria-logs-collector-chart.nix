{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-collector";
  version = "0.3.6";
  sha256 = "sha256-TrFKwY0MleTQn8TzcHT7znbjYAWJ3kCQ0FTkTS5kw7Y=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428"; }
    ];
  };
}
