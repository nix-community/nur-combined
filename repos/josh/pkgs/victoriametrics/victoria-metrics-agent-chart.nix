{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.44.0";
  sha256 = "sha256-IHsIz5VBy7fb+UvV1T3a8QR6/JgyW/499pL4qbxrcT8=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:8428/api/v1/write"; }
    ];
  };
}
