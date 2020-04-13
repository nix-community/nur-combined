let
  controlPort = 9051;
in
import ./make-test.nix (
  { pkgs, ... }: {
    name = "tor";
    nodes = {
      default = {
        environment.systemPackages = [ pkgs.jq ];
        priegger.services.prometheus.enable = true;
        priegger.services.tor.enable = true;
        services.prometheus.globalConfig.scrape_interval = "1s";
      };
    };

    testScript =
      ''
        start_all()
        default.wait_for_unit("multi-user.target")

        with subtest("should have tor running"):
            default.wait_for_unit("tor.service")
            default.wait_for_open_port(${toString controlPort})
            default.succeed(
                "cat /etc/ssh/ssh_config | "
                + "grep '^Host \*.onion\nProxyCommand /nix/store/[^/]*/bin/nc -xlocalhost:9050 -X5 %h %p$'"
            )
        
        with subtest("should have onion service info metrics"):
            default.wait_until_succeeds(
                "curl -sf 'http://127.0.0.1:9090/api/v1/query?query=tor_onion_service_info' | "
                + "jq '.data.result[0].value[1]' | grep '\"1\"'"
            )
      '';
  }
)
