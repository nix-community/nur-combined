{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.43.0";
  sha256 = "sha256-oIunxiV3y09qQE2jW6DF2I2gQLDEvsTptbVyYe7NXlw=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:8428/api/v1/write"; }
    ];
  };
}
