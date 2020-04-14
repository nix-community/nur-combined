let
  controlPort = 9051;
in
import ./lib/make-test.nix (
  { pkgs, ... }: {
    name = "tor";
    nodes = {
      default = {
        priegger.services.tor.enable = true;
        priegger.services.prometheus.enable = true;
        services.openssh.enable = true;
      };
    };

    testScript =
      ''
        def checkCommonProperties(machine):
            machine.require_unit_state("tor.service")
            machine.wait_for_open_port(${toString controlPort})
            machine.succeed(
                "cat /etc/ssh/ssh_config | "
                + "grep '^Host \*.onion\nProxyCommand /nix/store/[^/]*/bin/nc -xlocalhost:9050 -X5 %h %p$'"
            )


        start_all()

        with subtest("should not have onion service info metrics"):
            default.wait_for_unit("multi-user.target")
            checkCommonProperties(default)
            default.succeed("systemctl list-units | grep tor-onion-services.path")
            default.succeed(
                "curl -sf 'http://127.0.0.1:9100/metrics' | grep 'tor_onion_service_info{hostname=\".\\+\",name=\"ssh\"} 1'"
            )
            default.succeed(
                "echo 'foo 1' > /var/lib/prometheus-node-exporter-text-files/foo.prom"
            )
            default.succeed("curl -sf 'http://127.0.0.1:9100/metrics' | grep 'foo 1'")
      '';
  }
)
