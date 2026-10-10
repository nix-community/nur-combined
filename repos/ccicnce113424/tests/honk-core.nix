{ lib, ... }:
{

  name = "honk-core";

  meta = {
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };

  nodes = {
    server = {
      virtualisation.vlans = [ 1 ];

      networking.firewall.allowedTCPPorts = [ 80 ];

      services.nginx = {
        enable = true;
        statusPage = true;
      };
    };

    machine =
      { pkgs, ... }:
      {
        virtualisation.vlans = [ 1 ];

        environment.systemPackages = [
          pkgs.curl
          pkgs.jq
        ];

        # honk stages nfqueue rules at startup; without the netlink family it
        # falls back to a running configuration with nfqueue disabled, which
        # makes every configuration write look like a restart-required change.
        boot.kernelModules = [ "nfnetlink_queue" ];

        services.honk-core = {
          enable = true;
          doona.enable = true;

          # honk only hijacks the interfaces it is told about; `eth1` is the
          # one carrying this host's traffic.
          wanInterface = "eth1";
        };
      };
  };

  testScript = ''
    machine.wait_for_unit("honk.service")
    server.wait_for_unit("nginx.service")

    machine.wait_for_open_port(9527)

    # The web UI is served by honk's native API.
    machine.succeed(
        "curl --fail --max-time 10 -L http://127.0.0.1:9527/"
        " | grep -q '<title>doona</title>'"
    )

    # honk resolves symlinks when it loads an `include` and then refuses any
    # file outside the entry config's directory, so /etc/honk must be a tree
    # of real files (an `environment.etc` mode other than "symlink").
    machine.succeed("test -f /etc/honk/config.dae && ! test -L /etc/honk/config.dae")

    # Traffic to the server goes through honk and is routed to `direct`.
    machine.succeed("curl --fail --max-time 10 http://server/")
    honk_pid = machine.succeed("systemctl show -p MainPID --value honk.service").strip()

    # Writing configuration needs a login: create the first administrator and
    # keep the bearer token for the requests below.
    machine.succeed(
        "curl -sS -X POST -H 'Content-Type: application/json'"
        " -d '{\"username\":\"admin\",\"password\":\"honk-test-password\"}'"
        " http://127.0.0.1:9527/api/v1/auth/setup | jq -r .token > /tmp/token"
    )

    # Write a custom configuration fragment the way the web UI does.
    machine.succeed(
        "curl -sS -X POST -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -d '{\"path\":\"config.d/99-custom.dae\",\"content\":\"routing { dport(80) -> block }\"}'"
        " http://127.0.0.1:9527/api/v1/config/sources | jq -e .status"
    )
    machine.wait_until_succeeds(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -e '.sources[] | select(.path == \"config.d/99-custom.dae\")'"
    )
    machine.succeed("grep -q 'dport(80) -> block' /etc/honk/config.d/99-custom.dae")

    # The rule is live: port 80 is blocked now...
    machine.fail("curl --fail --max-time 5 http://server/")
    # ... and honk applied it by reloading, it is still the same process.
    machine.succeed(
        "test $(systemctl show -p MainPID --value honk.service) = " + honk_pid
    )
  '';

}
