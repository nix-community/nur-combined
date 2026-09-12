{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-mcp";
  version = "0.1.0";
  hash = "sha256-9dqEK7UN01IiEzM6JXGyeDVL78VCAJDllELJG5umOqM=";
  helmTestValues = {
    vl.entrypoint = "http://victoria-logs:9428";
  };

  meta = {
    description = "Helm chart for the VictoriaLogs MCP server, exposing LogsQL queries to MCP clients";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
