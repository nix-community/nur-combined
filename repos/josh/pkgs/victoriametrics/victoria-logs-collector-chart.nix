{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-collector";
  version = "0.3.4";
  sha256 = "sha256-1fIHvMJEEujBZhWS48gJKrUWVqHy+JdQ8OTsokkhOyY=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428"; }
    ];
  };
}
