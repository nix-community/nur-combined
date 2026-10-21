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
          tool.enable = true;

          # honk only hijacks the interfaces it is told about; `eth1` is the
          # one carrying this host's traffic.
          wanInterface = "eth1";

          # A user fragment lands in config.d/ like the generated ones.
          configFiles."30-user.dae".text = "# user fragment";
        };
      };
  };

  testScript = ''
    machine.wait_for_unit("honk-core.service")
    server.wait_for_unit("nginx.service")

    machine.wait_for_open_port(9527)

    # honk-tool comes from the module wrapper: DAE_LOCATION_ASSET points at
    # the same asset set as the service, so the geo subcommands need no flags.
    machine.succeed("honk-tool --version")
    machine.succeed("honk-tool geosite list | grep -q '^GOOGLE '")
    machine.succeed("honk-tool geoip list | grep -q '^CN '")

    # The package wrapper puts iproute2 on honk-tool's PATH; diagnose runs
    # `ip netns exec`, so an empty caller PATH must still reach `ip rule list`.
    status, out = machine.execute(
        "/run/current-system/sw/bin/env PATH=/nonexistent "
        "/run/current-system/sw/bin/honk-tool diagnose --api=",
        check_return=False,
    )
    assert "fwmark" in out, out

    # The nfqueue switch (on by default) loads the netlink family.
    machine.succeed("test -d /sys/module/nfnetlink_queue")
    machine.succeed("grep -q 'nfqueue_enable: true' /etc/honk/config.d/10-global.dae")

    # The web UI is served by honk's native API.
    machine.succeed(
        "curl --fail --max-time 10 -L http://127.0.0.1:9527/"
        " | grep -q '<title>doona</title>'"
    )

    # The entry config is a real file seeded once by tmpfiles: the blocks the
    # web UI edits and the import that loads config.d/.
    machine.succeed("test -f /etc/honk/config.dae && ! test -L /etc/honk/config.dae")
    machine.succeed("grep -qF 'global { }' /etc/honk/config.dae")
    machine.succeed("grep -qF 'routing { }' /etc/honk/config.dae")
    machine.succeed("grep -qF \"'config.d/*.dae'\" /etc/honk/config.dae")
    # The Nix-managed settings live beside it, inside the import; a fragment
    # declared in configFiles is placed and imported the same way (an invalid
    # file there would keep honk from starting).
    machine.succeed("grep -q 'native_api' /etc/honk/config.d/20-doona.dae")
    machine.succeed("grep -q 'user fragment' /etc/honk/config.d/30-user.dae")

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
    machine.succeed(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -r '.sources[] | select(.path == \"config.dae\")"
        " | [.id, .content_sha256] | @tsv' > /tmp/config-source"
    )

    # The entry config is the writable source the web UI writes: a global
    # setting and a routing rule, with the import kept.
    machine.succeed(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -e '.sources[] | select(.path == \"config.dae\" and .writable == true)'"
    )
    machine.succeed(
        "jq -n --arg content \"global { max_concurrent_dials: 8 } routing { dport(80) -> block } include { 'config.d/*.dae' }\""
        " '{content: $content}' > /tmp/body.json"
    )
    machine.succeed(
        "curl -sS --fail -X PUT -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -H \"If-Match: \\\"$(cut -f2 /tmp/config-source)\\\"\""
        " --data @/tmp/body.json"
        " http://127.0.0.1:9527/api/v1/config/sources/$(cut -f1 /tmp/config-source)"
    )
    machine.succeed("grep -q 'max_concurrent_dials: 8' /etc/honk/config.dae")
    machine.succeed("grep -q 'dport(80) -> block' /etc/honk/config.dae")

    # Nodes and subscriptions the API manages are appended to the entry config
    # (honk writes its main source), so they survive activation.
    machine.succeed(
        "curl -sS --fail -X POST -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -d '{\"name\":\"test-sub\",\"kind\":\"subscription\",\"url\":\"http://server/\"}'"
        " http://127.0.0.1:9527/api/v1/providers"
    )
    machine.succeed("grep -q 'test-sub' /etc/honk/config.dae")

    # A write that changes the native_api block stays refused.
    machine.succeed(
        "curl -sS -H \"Authorization: Bearer $(cat /tmp/token)\""
        " http://127.0.0.1:9527/api/v1/config"
        " | jq -r '.sources[] | select(.path == \"config.d/20-doona.dae\")"
        " | [.id, .content_sha256] | @tsv' > /tmp/doona-source"
    )
    machine.fail(
        "curl -sS --fail -X PUT -H \"Authorization: Bearer $(cat /tmp/token)\""
        " -H 'Content-Type: application/json'"
        " -H \"If-Match: \\\"$(cut -f2 /tmp/doona-source)\\\"\""
        " -d '{\"content\":\"experimental { native_api { enabled: false } }\"}'"
        " http://127.0.0.1:9527/api/v1/config/sources/$(cut -f1 /tmp/doona-source)"
    )

    # The rule is live: port 80 is blocked now...
    machine.fail("curl --fail --max-time 5 http://server/")
    # ... and honk applied it by reloading, it is still the same process.
    machine.succeed(
        "test $(systemctl show -p MainPID --value honk-core.service) = " + honk_pid
    )
  '';

}
