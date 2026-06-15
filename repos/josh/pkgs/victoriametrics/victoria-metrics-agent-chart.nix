{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.41.2";
  sha256 = "sha256-ciopct3pPaN3e4QZyuxW9c89TCMW0yWF6Qz6KsUkOZI=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:8428/api/v1/write"; }
    ];
  };
}
