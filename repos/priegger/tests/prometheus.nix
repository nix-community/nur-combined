let
  prometheusPort = 9090;
  nodeExporterPort = 9100;
  torExporterPort = 9130;
in
import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "prometheus";
    nodes = rec {
      default = {
        environment.systemPackages = [ pkgs.jq ];
        priegger.services.prometheus.enable = true;
        services.prometheus.globalConfig.scrape_interval = "1s";
      };
      customExporters = default // {
        services.prometheus.exporters.node.enable = false;
      };
      tor = default // {
        services.tor = {
          enable = true;
          controlPort = 9051;
        };
      };
    };

    testScript =
      ''
        start_all()

        with subtest("should have prometheus metrics"):
            default.wait_for_unit("prometheus.service")
            default.wait_for_open_port(${toString prometheusPort})
            default.succeed(
                "curl -s http://127.0.0.1:${toString prometheusPort}/metrics | "
                + "grep -q 'prometheus_build_info{.\\+} 1'"
            )
            default.wait_until_succeeds(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=prometheus_build_info' | "
                + "jq '.data.result[0].value[1]' | grep '\"1\"'"
            )

        with subtest("should have node_exporter metrics"):
            default.wait_for_unit("prometheus-node-exporter.service")
            default.wait_for_open_port(${toString nodeExporterPort})
            default.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics"
                + " | grep -q 'node_exporter_build_info{.\\+} 1'"
            )
            default.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics"
                + " | grep -q 'node_scrape_collector_success{collector=\"logind\"} 1'"
            )
            default.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics"
                + " | grep -q 'node_scrape_collector_success{collector=\"systemd\"} 1'"
            )
            default.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics"
                + " | grep -q 'node_scrape_collector_success{collector=\"tcpstat\"} 1'"
            )
            default.succeed("test -d /var/lib/prometheus-node-exporter-text-files")
            default.succeed(
                "curl -s http://127.0.0.1:${toString nodeExporterPort}/metrics | grep -q 'system_version NaN'"
            )
            default.succeed(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/targets' | "
                + "jq '.data.activeTargets[] | .scrapePool' | grep '\"node\"'"
            )
            default.wait_until_succeeds(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=node_exporter_build_info' | "
                + "jq '.data.result[0].value[1]' | grep '\"1\"'"
            )

        with subtest("should have alerting rules"):
            default.wait_for_unit("prometheus.service")
            default.wait_for_open_port(${toString prometheusPort})
            default.succeed(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/rules' | "
                + "jq '.data.groups[] | .name' | grep '\"node\"'"
            )
            default.succeed(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/rules' | "
                + "jq '.data.groups[] | .name' | grep '\"prometheus\"'"
            )

        with subtest("should allow overriding node exporter config"):
            customExporters.wait_for_unit("prometheus.service")
            customExporters.wait_for_open_port(${toString prometheusPort})
            customExporters.fail(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/targets' | "
                + "jq '.data.activeTargets[] | .scrapePool' | grep '\"node\"'"
            )
            customExporters.fail(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/rules' | "
                + "jq '.data.groups[] | .name' | grep '\"node\"'"
            )
            customExporters.fail("test -d /var/lib/prometheus-node-exporter-text-files")

        with subtest("should have tor metrics"):
            tor.wait_for_unit("prometheus-tor-exporter.service")
            tor.wait_for_open_port(${toString torExporterPort})
            tor.succeed("curl -s http://127.0.0.1:${toString torExporterPort}/metrics | grep -q 'tor_version{.\\+} 1'")
            tor.wait_for_unit("prometheus.service")
            tor.wait_until_succeeds(
                "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=tor_version' | "
                + "jq '.data.result[0].value[1]' | grep '\"1\"'"
            )
      '';
  }
)
