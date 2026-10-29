{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  fixture = import ./realm-spire-fixture.nix {
    inherit pkgs;
    host = "eihort";
  };
in
pkgs.testers.runNixOSTest {
  name = "realm-identity-metrics";
  nodes.machine =
    { config, lib, ... }:
    {
      imports = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/realm-observability.nix
        ../nixosModules/realm-internet.nix
        ../nixosModules/service-discovery.nix
        fixture.module
      ];
      virtualisation = {
        memorySize = 3072;
        cores = 2;
      };
      networking.hostName = "eihort";
      networking.interfaces.eth1.ipv4.addresses = [
        {
          address = "10.9.8.91";
          prefixLength = 32;
        }
      ];
      system.stateVersion = "26.05";
      environment.systemPackages = [
        pkgs.curl
        pkgs.jq
        pkgs.spire
        pkgs.python3
      ];
      realm = {
        enable = true;
        address = "::1";
        serviceDiscovery = {
          enable = true;
          address = "::1";
        };
        observability.enable = true;
        internet = {
          enable = true;
          allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
        };
        spire.metrics = {
          enable = true;
          nodes = [ "eihort" ];
          independent = {
            enable = true;
            address = "10.9.8.91";
            observers = [ "10.9.8.91/32" ];
          };
        };
        workloads = {
          sender.egress.receiver = {
            service = "receiver";
            verifyID = "spiffe://nyaw.xyz/service/receiver";
            localPort = 13100;
          };
          receiver.ingress.http = {
            port = 19429;
            target = "127.0.0.1:3030";
            privateLoopback = true;
            service = "receiver";
            allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
          };
        };
      };
      services.spire.server.settings.server = {
        default_x509_svid_ttl = lib.mkForce "60s";
        agent_ttl = "10m";
      };
      users.groups = {
        sender = { };
        receiver = { };
      };
      users.users = {
        sender = {
          isSystemUser = true;
          group = "sender";
        };
        receiver = {
          isSystemUser = true;
          group = "receiver";
        };
      };
      systemd.services.sender.serviceConfig = {
        User = "sender";
        ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
      };
      systemd.services.receiver.serviceConfig = {
        User = "receiver";
        ExecStart = "${pkgs.python3}/bin/python3 -m http.server 3030 --bind 127.0.0.1";
      };
    };
  testScript = ''
    import json
    import shlex
    import time

    start_all()
    machine.wait_for_unit("realm-node-attest-responder.service")
    machine.succeed("curl -fsS http://127.0.0.1:18493/metrics")
    machine.succeed("ip address replace fdcc::91/128 dev lo")
    machine.wait_for_unit("spire-server.service")
    machine.wait_for_unit("realm-spire-register.service")
    entries = json.loads(machine.succeed("spire-server entry show -socketPath /run/spire/server/private/api.sock -output json"))["entries"]
    for entry in entries:
        identity = entry["spiffe_id"]
        if not identity["path"].startswith(("/service/", "/observer/")):
            continue
        parent = entry["parent_id"]
        args = ["spire-server", "entry", "update", "-socketPath", "/run/spire/server/private/api.sock", "-entryID", entry["id"], "-spiffeID", "spiffe://" + identity["trust_domain"] + identity["path"], "-parentID", "spiffe://" + parent["trust_domain"] + parent["path"], "-x509SVIDTTL", "60"]
        for selector in entry["selectors"]:
            args.extend(["-selector", selector["type"] + ":" + selector["value"]])
        machine.succeed(shlex.join(args))
    machine.succeed("spire-server bundle show -socketPath /run/spire/server/private/api.sock > /run/bootstrap.pem")
    machine.succeed("systemctl start --no-block spire-agent.service")
    machine.wait_for_unit("spire-agent.service", timeout=90)
    machine.wait_for_unit("realm-identity-metrics.service")
    machine.wait_for_unit("realm-observability.service")
    machine.wait_until_succeeds("curl -fsS http://127.0.0.1:18494/healthz", timeout=120)

    def metrics():
        return machine.succeed("curl -fsS http://127.0.0.1:18494/metrics")

    def value(raw, name, **labels):
        for line in raw.splitlines():
            if line.startswith(name + "{") and all(f'{key}="{val}"' in line for key, val in labels.items()):
                return float(line.rsplit(" ", 1)[1])
        raise AssertionError((name, labels))

    initial = metrics()
    assert value(initial, "realm_bootstrap_bundle_server_trust_valid", node="eihort") == 1
    assert value(initial, "realm_spire_agent_metadata_valid", node="eihort") == 1
    assert value(initial, "realm_spire_alias_matches_expected", node="eihort") == 1
    assert value(initial, "realm_identity_certificate_not_after_seconds", kind="agent") > time.time()
    assert value(initial, "realm_identity_certificate_not_after_seconds", kind="canary") > time.time()
    assert value(initial, "realm_workload_svid_observation_success", unit="realm-observability.service", source="caddy_loaded") == 1
    assert value(initial, "realm_workload_svid_observation_success", unit="realm-internet.service", source="caddy_loaded") == 1
    assert value(initial, "realm_workload_svid_not_after_seconds", unit="realm-internet.service") > time.time()
    machine.succeed("curl --noproxy '*' -fsS http://127.0.0.1:19329/metrics | grep '^caddy_'")
    machine.fail("curl --noproxy '*' -fsS http://127.0.0.1:19329/config/")
    machine.fail("curl --noproxy '*' -ksf https://127.0.0.1:19330/")
    assert value(initial, "realm_workload_svid_dormant", unit="realm-egress-sender-receiver.service") == 1
    assert "PRIVATE KEY" not in initial

    machine.succeed("curl -fsS http://127.0.0.1:18495/metrics > /tmp/native-agent.metrics")
    machine.succeed("curl -fsS http://127.0.0.1:18496/metrics > /tmp/native-server.metrics")
    machine.succeed("grep -q '^spire_' /tmp/native-agent.metrics; grep -q '^spire_' /tmp/native-server.metrics")
    agent_events = machine.succeed("curl -fsS http://127.0.0.1:18491/metrics")
    server_events = machine.succeed("curl -fsS http://127.0.0.1:18492/metrics")
    assert value(agent_events, "realm_http_attestation_total", component="agent", outcome="success") >= 1
    assert value(server_events, "realm_http_attestation_total", component="server", outcome="success") >= 1

    machine.succeed("systemctl start receiver.service")
    machine.wait_for_unit("receiver.service")
    machine.succeed("systemctl start realm-ingress-receiver-http.service")
    machine.succeed("systemctl start realm-egress-sender-receiver.service")
    machine.wait_until_succeeds("curl -fsS http://127.0.0.1:18494/metrics | grep 'realm_workload_svid_observation_success.*realm-egress-sender-receiver.service.* 1$'", timeout=90)
    observed = metrics()
    assert value(observed, "realm_workload_svid_observation_success", unit="realm-ingress-receiver-http.service", source="ghostunnel_status_watch") == 1
    assert value(observed, "realm_workload_svid_not_after_seconds", unit="realm-egress-sender-receiver.service") > time.time()
    assert value(observed, "realm_workload_svid_not_after_seconds", unit="realm-ingress-receiver-http.service") > time.time()
    machine.succeed("curl -fsS http://10.9.8.91:18497/metrics > /tmp/independent.metrics")
    machine.fail("curl --interface 127.0.0.2 --max-time 2 -fsS http://10.9.8.91:18497/metrics")

    gateway_process = machine.succeed("systemctl show realm-internet -p MainPID -p NRestarts")
    machine.wait_until_succeeds("curl -fsS http://127.0.0.1:18494/metrics | grep 'realm_workload_svid_last_rotation_timestamp_seconds.*realm-internet.service'", timeout=120)
    assert machine.succeed("systemctl show realm-internet -p MainPID -p NRestarts") == gateway_process
    old_pid = machine.succeed("systemctl show realm-identity-metrics -p MainPID --value").strip()
    machine.succeed("systemctl mask --runtime spire-agent.service; systemctl stop --job-mode=replace-irreversibly spire-agent.service")
    machine.wait_until_succeeds("curl -fsS http://10.9.8.91:18497/metrics | grep 'realm_identity_collector_success.*canary.* 0$'", timeout=90)
    assert machine.succeed("systemctl show realm-identity-metrics -p MainPID --value").strip() == old_pid
    machine.fail("curl -fsS http://127.0.0.1:18494/healthz")
    machine.succeed("systemctl unmask --runtime spire-agent.service; systemctl start spire-agent.service")
    machine.wait_until_succeeds("curl -fsS http://127.0.0.1:18494/healthz", timeout=120)
  '';
}
