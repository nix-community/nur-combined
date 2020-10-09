let
  controlPort = 9051;
  prometheusPort = 9090;
  torExporterPort = 9130;
in
import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "tor";
    nodes = {
      tor = {
        environment.systemPackages = [ pkgs.jq ];
        priegger.services.tor.enable = true;
        priegger.services.prometheus.enable = true;
        services.openssh.enable = true;
      };
    };

    testScript =
      ''
        with subtest("should start tor"):
            tor.wait_for_unit("tor.service")
            tor.wait_for_open_port(${toString controlPort})

        with subtest("should have ssh tor config"):
            tor.succeed(
                "cat /etc/ssh/ssh_config | "
                + "grep '^Host \*.onion\nProxyCommand /nix/store/[^/]*/bin/nc -xlocalhost:9050 -X5 %h %p$'"
            )

        # TODO: There is some rate limiting/cpu usage issue, so this is disabled for now.

        # with subtest("should have onion service info metrics"):
        #     tor.succeed("systemctl list-units | grep tor-onion-services.path")
        #     tor.succeed(
        #         "curl -sf 'http://127.0.0.1:9100/metrics' | grep 'tor_onion_service_info{hostname=\".\\+\",name=\"ssh\"} 1'"
        #     )

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
