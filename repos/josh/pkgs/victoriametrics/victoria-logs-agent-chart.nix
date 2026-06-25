{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-agent";
  version = "0.2.8";
  sha256 = "sha256-Gn+jBTav5SJRFXCcC7ubZ2mFNYML6AQWcA5cbB3ahOA=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428/insert/jsonline"; }
    ];
  };
}
