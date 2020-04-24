let
  cadvisorPort = 18080;
  dockerPort = 9323;
  prometheusPort = 9090;
in
import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "docker";
    nodes = {
      docker = {
        environment.systemPackages = [ pkgs.jq ];
        priegger.services.docker.enable = true;
        services.prometheus.enable = true;
      };
    };

    testScript =
      ''
        docker.wait_for_unit("docker.service")
        docker.wait_for_open_port(${toString dockerPort})

        docker.wait_for_unit("cadvisor.service")
        docker.wait_for_open_port(${toString cadvisorPort})

        docker.wait_for_unit("prometheus.service")
        docker.wait_for_open_port(${toString prometheusPort})
        docker.wait_until_succeeds(
            "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=engine_daemon_engine_info' | "
            + "jq '.data.result[0].value[1]' | grep '\"1\"'"
        )
        docker.wait_until_succeeds(
            "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=cadvisor_version_info' | "
            + "jq '.data.result[0].value[1]' | grep '\"1\"'"
        )
      '';
  }
)
