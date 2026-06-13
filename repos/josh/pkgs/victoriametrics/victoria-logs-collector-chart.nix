{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-collector";
  version = "0.3.5";
  sha256 = "sha256-V2u9WkvAC0m7AnmiGP5Ph9IbAaLU09oeYDxfQ/WtxoM=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:9428"; }
    ];
  };
}
