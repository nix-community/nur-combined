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

        services.honk-core = {
          enable = true;

          # honk only hijacks the interfaces it is told about; `eth1` is the
          # one carrying this host's traffic.
          wanInterface = "eth1";
        };
      };
  };

  testScript = ''
    machine.wait_for_unit("honk-core.service")
    server.wait_for_unit("nginx.service")

    machine.wait_for_open_port(9527)

    # The nfqueue switch (on by default) loads the netlink family.
    machine.succeed("test -d /sys/module/nfnetlink_queue")
    machine.succeed("grep -q 'nfqueue_enable: true' /etc/honk/entry.dae")

    # The web UI is served by honk's native API.
    machine.succeed(
        "curl --fail --max-time 10 -L http://127.0.0.1:9527/"
        " | grep -q '<title>doona</title>'"
    )

    # honk resolves symlinks when it loads an `include` and then refuses any
    # file outside the entry config's directory, so /etc/honk must be a tree
    # of real files (an `environment.etc` mode other than "symlink").
    machine.succeed("test -f /etc/honk/entry.dae && ! test -L /etc/honk/entry.dae")

    # The entry carries the startup-only settings; the editable global and
    # routing blocks live in the writable /etc/honk/config.dae.
    machine.succeed("grep -q 'native_api' /etc/honk/entry.dae")
    machine.fail("grep -q 'routing' /etc/honk/entry.dae")
    machine.succeed("grep -qF 'global { } routing { }' /etc/honk/config.dae")

    # Traffic to the server goes through honk and is routed to `direct`.
    machine.succeed("curl --fail --max-time 10 http://server/")
    honk_pid = machine.succeed("systemctl show -p MainPID --value honk-core.service").strip()

    # Writing configuration needs a login: create the first administrator and
    # keep the bearer token for the requests below.
    machine.succeed(
        "curl -sS -X POST -H 'Content-Type: application/json'"
        " -d '{\"username\":\"admin\",\"password\":\"honk-test-password\"}'"
        " http://127.0.0.1:9527/api/v1/auth/setup | jq -r .token > /tmp/token"
    )

    # The entry cannot be rewritten through the web: doona never offers a file
    # with listener settings for editing, and honk refuses any write that
    # would change its native_api block.
    machine.succeed(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -r '.sources[] | select(.kind == \"main\")"
        " | [.id, .content_sha256] | @tsv' > /tmp/entry-source"
    )
    machine.fail(
        "curl -sS --fail -X PUT -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -H \"If-Match: \\\"$(cut -f2 /tmp/entry-source)\\\"\""
        " -d '{\"content\":\"global { } experimental { native_api { enabled: false } }\"}'"
        " http://127.0.0.1:9527/api/v1/config/sources/$(cut -f1 /tmp/entry-source)"
    )
    machine.succeed(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -e '.sources[] | select(.path == \"config.dae\" and .writable == true)'"
    )

    # Replace that source's contents the way doona's simple rule page does.
    machine.succeed(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -r '.sources[] | select(.path == \"config.dae\")"
        " | [.id, .content_sha256] | @tsv' > /tmp/config-source"
    )
    machine.succeed(
        "curl -sS --fail -X PUT -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -H \"If-Match: \\\"$(cut -f2 /tmp/config-source)\\\"\""
        " -d '{\"content\":\"global { } routing { dport(80) -> block }\"}'"
        " http://127.0.0.1:9527/api/v1/config/sources/$(cut -f1 /tmp/config-source)"
    )
    machine.succeed("grep -q 'dport(80) -> block' /etc/honk/config.dae")

    # Creating a fragment under config.d/ works as well.
    machine.succeed(
        "curl -sS -X POST -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -d '{\"path\":\"config.d/99-custom.dae\",\"content\":\"# custom fragment\"}'"
        " http://127.0.0.1:9527/api/v1/config/sources | jq -e .status"
    )
    machine.succeed("grep -q 'custom fragment' /etc/honk/config.d/99-custom.dae")

    # The rule is live: port 80 is blocked now...
    machine.fail("curl --fail --max-time 5 http://server/")
    # ... and honk applied it by reloading, it is still the same process.
    machine.succeed(
        "test $(systemctl show -p MainPID --value honk-core.service) = " + honk_pid
    )
  '';

}
