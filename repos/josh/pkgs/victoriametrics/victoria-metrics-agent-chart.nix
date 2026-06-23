{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.42.0";
  sha256 = "sha256-0YtLqjtvrpQdubefJeEuHMjPyWLIb+wrBE3AfUSf9OM=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:8428/api/v1/write"; }
    ];
  };
}
