{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-agent";
  version = "0.2.5";
  sha256 = "sha256-7ZANRKY9ZbYN8GyeCfKdwpNVglsNP2GID9vsZKsIiCE=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428/insert/jsonline"; }
    ];
  };
}
