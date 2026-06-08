{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.41.0";
  sha256 = "sha256-hbjQ8Jqu/HiMFMqKUWVReOGGOFCe1zxohDojRbcWdrQ=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:8428/api/v1/write"; }
    ];
  };
}
