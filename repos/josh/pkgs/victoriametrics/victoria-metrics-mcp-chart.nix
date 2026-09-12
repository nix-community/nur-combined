{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-mcp";
  version = "0.3.0";
  hash = "sha256-w5MmCs+nkAuloA4kk/hzdefTUEONPLXciB4bunsQ5h8=";
  helmTestValues = {
    vm.entrypoint = "http://victoria-metrics:8428";
  };

  meta = {
    description = "Helm chart for the VictoriaMetrics MCP server, exposing MetricsQL queries to MCP clients";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
