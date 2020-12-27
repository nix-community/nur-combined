let
  prometheusPort = 9090;
  nodeExporterPort = 9100;
in
import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "prometheus";
    nodes = rec {
      prometheus = {
        environment.systemPackages = [ pkgs.jq ];
        priegger.services.prometheus.enable = true;
        services.prometheus.globalConfig.scrape_interval = "1s";
      };
      prometheusWithoutNodeExporter = prometheus // {
        services.prometheus.exporters.node.enable = false;
      };
    };

    testScript =
      ''
        start_all()

        with subtest("should have prometheus metrics"):
            prometheus.wait_for_unit("prometheus.service")
            prometheus.wait_for_open_port(${toString prometheusPort})
            prometheus.succeed(
                "curl -s http://127.0.0.1:${toString prometheusPort}/metrics | "
                + "grep -q 'prometheus_build_info{.\\+} 1'"
            )
            prometheus.wait_until_succeeds(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=prometheus_build_info' | "
                + "jq '.data.result[0].value[1]' | grep '\"1\"'"
            )

        with subtest("should have node_exporter metrics"):
            prometheus.wait_for_unit("prometheus-node-exporter.service")
            prometheus.wait_for_open_port(${toString nodeExporterPort})
            prometheus.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics"
                + " | grep -q 'node_exporter_build_info{.\\+} 1'"
            )

            for collector in ["logind", "systemd", "tcpstat"]:
                prometheus.succeed(
                    "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics"
                    + " | grep -q 'node_scrape_collector_success{collector=\""
                    + collector
                    + "\"} 1'"
                )

            prometheus.succeed("test -d /var/lib/prometheus-node-exporter-text-files")
            prometheus.succeed(
                "echo 'foo 1' > /var/lib/prometheus-node-exporter-text-files/foo.prom"
            )
            prometheus.succeed("curl -sf 'http://127.0.0.1:9100/metrics' | grep 'foo 1'")

            prometheus.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics | grep -q '^system_version NaN$'"
            )
            prometheus.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics | grep -q '^system_activation_time_seconds '"
            )
            prometheus.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics | grep -q 'system_nixpkgs_time_seconds NaN$'"
            )

            prometheus.succeed(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/targets' | "
                + "jq '.data.activeTargets[] | .scrapePool' | grep '\"node\"'"
            )
            prometheus.wait_until_succeeds(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=node_exporter_build_info' | "
                + "jq '.data.result[0].value[1]' | grep '\"1\"'"
            )

        with subtest("should have alerting rules"):
            prometheus.succeed(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/rules' | "
                + "jq '.data.groups[] | .name' | grep '\"node\"'"
            )
            prometheus.succeed(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/rules' | "
                + "jq '.data.groups[] | .name' | grep '\"prometheus\"'"
            )

        with subtest("should allow overriding node exporter config"):
            prometheusWithoutNodeExporter.wait_for_unit("prometheus.service")
            prometheusWithoutNodeExporter.wait_for_open_port(${toString prometheusPort})
            prometheusWithoutNodeExporter.fail(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/targets' | "
                + "jq '.data.activeTargets[] | .scrapePool' | grep '\"node\"'"
            )
            prometheusWithoutNodeExporter.fail(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/rules' | "
                + "jq '.data.groups[] | .name' | grep '\"node\"'"
            )
            prometheusWithoutNodeExporter.fail(
                "test -d /var/lib/prometheus-node-exporter-text-files"
            )
      '';
  }
)
