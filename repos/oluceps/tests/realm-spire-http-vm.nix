{ nixpkgs }:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [ ];
  };
  spireFixture = import ./realm-spire-fixture.nix {
    inherit pkgs;
    host = "abhoth";
  };
  python = pkgs.python3.withPackages (p: [ p.cryptography ]);
  controlChecks = pkgs.writeText "realm-spire-http-control-checks.py" ''
    import base64
    import errno
    import hashlib
    import http.client
    import json
    import os
    import pwd
    import socket
    import stat
    import subprocess
    import sys
    import time

    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

    CONTROL = "/run/realm-node-attest/control.sock"
    PUBLIC = "/.well-known/spire-node-attestation/v1/"
    HOST = "abhoth.nyaw.xyz:18091"
    API = "/run/spire/agent/public/api.sock"

    def request(method, path, body=None, host=HOST, control=False, address="fdcc::91"):
        connection = http.client.HTTPConnection(address, 18091, timeout=5)
        if control:
            connection.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            connection.sock.settimeout(5)
            connection.sock.connect(CONTROL)
        try:
            connection.request(method, path, body=body, headers={"Host": host})
            response = connection.getresponse()
            return response.status, dict(response.getheaders()), response.read()
        finally:
            connection.close()

    def as_user(uid, gid, *args):
        def credentials():
            os.setgroups([])
            os.setgid(gid)
            os.setuid(uid)
        return subprocess.run(
            [sys.executable, __file__, *args],
            preexec_fn=credentials, capture_output=True, text=True, timeout=10,
        )

    def denied_connect(path):
        connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            connection.connect(path)
        except OSError as error:
            assert error.errno == errno.EACCES, error
        else:
            raise AssertionError("The account reached the protected socket")
        finally:
            connection.close()

    def b64(value):
        return base64.urlsafe_b64encode(value).decode().rstrip("=")

    def encoded(value):
        return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()

    if len(sys.argv) > 1:
        if sys.argv[1] == "connect-denied":
            denied_connect(sys.argv[2])
        elif sys.argv[1] == "peer-denied":
            assert request("DELETE", "/v1/proofs/" + b64(bytes(32)), control=True)[0] == 403
        else:
            raise AssertionError(sys.argv)
        sys.exit(0)

    fixture = pwd.getpwnam("fixture")
    metadata = os.stat(CONTROL)
    assert stat.S_ISSOCK(metadata.st_mode)
    assert metadata.st_uid == metadata.st_gid == 0
    assert stat.S_IMODE(metadata.st_mode) == 0o600
    result = as_user(fixture.pw_uid, fixture.pw_gid, "connect-denied", CONTROL)
    assert result.returncode == 0, result.stderr

    # Relax the file mode to test SO_PEERCRED independently of file permissions.
    try:
        os.chmod(CONTROL, 0o666)
        result = as_user(fixture.pw_uid, fixture.pw_gid, "peer-denied")
        assert result.returncode == 0, result.stderr
    finally:
        os.chmod(CONTROL, 0o600)

    key = Ed25519PrivateKey.generate()
    public_key = key.public_key().public_bytes(
        serialization.Encoding.Raw, serialization.PublicFormat.Raw,
    )
    jwk = {"kty": "OKP", "crv": "Ed25519", "x": b64(public_key)}
    challenge_id = b64(os.urandom(32))
    challenge = {
        "version": 1,
        "challenge_id": challenge_id,
        "nonce": b64(os.urandom(32)),
        "fqdn": "abhoth.nyaw.xyz",
        "trust_domain": "nyaw.xyz",
        "server_id": "spiffe://nyaw.xyz/spire/server",
        "bootstrap_key_thumbprint": b64(hashlib.sha256(encoded(jwk)).digest()),
        "expires_at": int(time.time()) + 12,
    }
    protected = b64(encoded({"alg": "EdDSA", "typ": "spire-http-node-attestation+jws"}))
    signing_input = protected + "." + b64(encoded(challenge))
    compact = signing_input + "." + b64(key.sign(signing_input.encode()))
    proof = encoded({"bootstrap_jwk": jwk, "proof": compact})
    path = PUBLIC + challenge_id
    control_path = "/v1/proofs/" + challenge_id
    assert request("PUT", control_path, proof, control=True)[0] == 201
    status, headers, body = request("GET", path)
    assert status == 200 and body == proof, (status, body)
    assert headers["Cache-Control"] == "no-store", headers
    assert headers["Content-Type"] == "application/json", headers
    assert headers["X-Content-Type-Options"] == "nosniff", headers
    assert b"PRIVATE KEY" not in body

    for method in ["POST", "PUT", "DELETE", "HEAD"]:
        assert request(method, path)[0] == 405, method
    for bad_path in [
        "/", "/etc/passwd", PUBLIC, PUBLIC + b64(bytes(32)),
        path + "?query=1", PUBLIC + "%" + format(ord(challenge_id[0]), "02x") + challenge_id[1:],
        path + "/extra", PUBLIC + "../control.sock", "/v1/proofs/" + challenge_id,
    ]:
        assert request("GET", bad_path)[0] == 404, bad_path
    for host in ["other.nyaw.xyz:18091", "abhoth.nyaw.xyz", "[fdcc::91]:18091"]:
        assert request("GET", path, host=host)[0] == 404, host
    assert request("GET", path, body=b"unexpected")[0] == 404
    assert request("PUT", control_path, b"{}", control=True)[0] == 400
    assert request("PUT", control_path, b"x" * 8193, control=True)[0] == 400
    assert request("PUT", "/v1/proofs/" + b64(bytes(32)), proof, control=True)[0] == 400
    assert request("DELETE", control_path, control=True)[0] == 204
    assert request("GET", path)[0] == 404
    assert request("PUT", control_path, proof, control=True)[0] == 201
    while time.time() <= challenge["expires_at"]:
        time.sleep(0.25)
    assert request("GET", path)[0] == 404
    assert request("PUT", control_path, proof, control=True)[0] == 400
  '';
in
pkgs.testers.runNixOSTest {
  name = "realm-spire-http-attestation";
  globalTimeout = 900;
  nodes.machine =
    { config, lib, ... }:
    {
      imports = [
        ../nixosModules/realm-workloads.nix
        spireFixture.module
        ../nixosModules/service-discovery.nix
      ];
      virtualisation.memorySize = 2048;
      virtualisation.vlans = [ ];
      networking = {
        hostName = "abhoth";
        useDHCP = false;
        nameservers = [ "::1" ];
        firewall.extraCommands = ''
          iptables -A OUTPUT ! -o lo -j REJECT
          ip6tables -A OUTPUT ! -o lo -j REJECT
        '';
      };
      environment.etc."realm-spire-http-agent.conf".source = config.services.spire.agent.configFile;
      environment.etc."realm-spire-http-server.conf".source = config.services.spire.server.configFile;
      environment.etc."realm-spire-http-policy.json".source =
        config.services.spire.server.settings.plugins.NodeAttestor.http_fqdn.plugin_data.config_file;
      environment.systemPackages = [
        pkgs.spire
        pkgs.openssl
        pkgs.dnsutils
        pkgs.jq
        python
      ];
      users.groups = {
        fixture = { };
        imposter = { };
      };
      users.users = lib.genAttrs [ "fixture" "imposter" ] (name: {
        isSystemUser = true;
        group = name;
        extraGroups = [ "realm-proxies" ];
      });
      realm = {
        enable = true;
        address = "::1";
        serviceDiscovery = {
          enable = true;
          address = "::1";
        };
        spire = {
          registrations.fixture = {
            spiffeID = "spiffe://nyaw.xyz/service/http-fixture";
            selectors = [
              "systemd:id:realm-fixture.service"
              "unix:user:fixture"
            ];
          };
        };
      };
      # A fixed test directory permits a fresh attestation without cached SVIDs.
      systemd.services.spire-agent.serviceConfig.StateDirectory = lib.mkForce "realm-spire-http-vm";
      systemd.services.realm-fixture = {
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "fixture";
          Group = "fixture";
          SupplementaryGroups = [ "realm-proxies" ];
          RuntimeDirectory = "realm-http-svid";
          RuntimeDirectoryMode = "0700";
          ExecStart = "${pkgs.spire}/bin/spire-agent api fetch x509 -socketPath ${config.realm.spire.socket} -timeout 10s -write /run/realm-http-svid";
        };
      };
    };
  testScript = ''
    import json
    import shlex

    agent_id = "spiffe://nyaw.xyz/spire/agent/http_fqdn/abhoth"
    alias_id = "spiffe://nyaw.xyz/agent/abhoth"
    workload_id = "spiffe://nyaw.xyz/service/http-fixture"
    admin_socket = "/run/spire/server/private/api.sock"

    def admin(command):
        return f"spire-server {command} -socketPath {admin_socket}"

    def fresh_agent():
        machine.succeed("systemctl stop spire-agent.service")
        machine.succeed("rm -rf /var/lib/realm-spire-http-vm/*")
        machine.succeed("systemctl reset-failed spire-agent.service")

    def entries(identity):
        data = json.loads(machine.succeed(admin(f"entry show -spiffeID {identity} -output json")))
        return [
            {key: entry[key] for key in ["id", "parent_id", "spiffe_id", "selectors"]}
            for entry in data.get("entries", [])
        ]

    def issue():
        machine.succeed("systemctl stop realm-fixture.service")
        machine.succeed("systemctl start realm-fixture.service")
        machine.succeed("test -s /run/realm-http-svid/svid.0.pem && test -s /run/realm-http-svid/svid.0.key")
        certificate = machine.succeed("openssl x509 -in /run/realm-http-svid/svid.0.pem -noout -ext subjectAltName")
        assert "URI:" + workload_id in certificate, certificate
        machine.succeed("openssl verify -CAfile /run/bootstrap.pem -untrusted /run/realm-http-svid/svid.0.pem /run/realm-http-svid/svid.0.pem")
        machine.succeed("openssl x509 -in /run/realm-http-svid/svid.0.pem -pubkey -noout > /tmp/certificate-public.pem")
        machine.succeed("openssl pkey -in /run/realm-http-svid/svid.0.key -pubout > /tmp/key-public.pem; cmp /tmp/certificate-public.pem /tmp/key-public.pem")

    machine.start()
    machine.wait_for_unit("spire-server.service")
    machine.wait_for_unit("realm-spire-register.service")
    machine.succeed("ip address replace fdcc::91/128 dev lo")
    for name in ["control", "http6"]:
        machine.wait_for_unit(f"realm-node-attest-{name}.socket")

    with subtest("the sockets activate the independent helper"):
        machine.fail("systemctl is-active --quiet realm-node-attest-responder.service")
        machine.fail("systemctl is-active --quiet spire-agent.service")
        machine.succeed("${python}/bin/python3 ${controlChecks}")
        machine.wait_for_unit("realm-node-attest-responder.service")

    with subtest("the agent has a public bundle and no join token"):
        machine.succeed(admin("bundle show") + " > /run/bootstrap.pem")
        machine.succeed("openssl x509 -in /run/bootstrap.pem -noout")
        machine.succeed("test ! -e /var/lib/realm-spire/join-token")
        machine.succeed("! grep -q PRIVATE /run/bootstrap.pem")
        machine.succeed("! grep -q join_token /etc/realm-spire-http-agent.conf")
        machine.succeed("! grep -q join_token /etc/realm-spire-http-server.conf")

    with subtest("literal address pins attest the agent without DNS and preserve the stable parent"):
        policy = json.loads(machine.succeed("cat /etc/realm-spire-http-policy.json"))
        assert "dns_resolver" not in policy, policy
        assert policy["nodes"] == {"abhoth": {"fqdn": "abhoth.nyaw.xyz", "addresses": ["fdcc::91"]}}, policy
        machine.fail("dig @::1 +time=1 +tries=1 abhoth.nyaw.xyz AAAA")
    ${spireFixture.startAgent}
    with subtest("native HTTP attestation preserves the stable parent"):
        description = json.loads(machine.succeed(admin(f"agent show -spiffeID {agent_id} -output json")))
        assert description["attestation_type"] == "http_fqdn", description
        assert description["can_reattest"] is True, description
        aliases = entries(alias_id)
        assert len(aliases) == 1, aliases
        assert aliases[0]["parent_id"] == {
            "trust_domain": "nyaw.xyz", "path": "/spire/agent/http_fqdn/abhoth",
        }, aliases
        assert {"type": "spiffe_id", "value": agent_id} in aliases[0]["selectors"], aliases
        workloads = entries(workload_id)
        assert len(workloads) == 1, workloads
        parent = workloads[0]["parent_id"]
        assert parent["trust_domain"] == "nyaw.xyz" and parent["path"] == "/agent/abhoth", parent
        issue()

    with subtest("the responder cannot reach the Workload API"):
        pid = machine.succeed("systemctl show realm-node-attest-responder.service -p MainPID --value").strip()
        uid = int(machine.succeed(f"awk '/^Uid:/ {{print $2}}' /proc/{pid}/status"))
        gid = int(machine.succeed(f"awk '/^Gid:/ {{print $2}}' /proc/{pid}/status"))
        groups = [int(group) for group in machine.succeed(f"awk '/^Groups:/ {{for (i=2; i<=NF; i++) print $i}}' /proc/{pid}/status").split()]
        proxy_gid = int(machine.succeed("getent group realm-proxies | cut -d: -f3"))
        assert uid != 0 and proxy_gid not in groups, (uid, groups)
        command = (
            f"import os, subprocess; os.setgroups({groups}); "
            f"os.setgid({gid}); os.setuid({uid}); "
            f"subprocess.run(['${python}/bin/python3', '${controlChecks}', 'connect-denied', '/run/spire/agent/public/api.sock'], check=True)"
        )
        machine.succeed("${python}/bin/python3 -c " + shlex.quote(command))

    with subtest("workload selectors require both the unit and the account"):
        machine.fail(
            "systemd-run --wait --collect --unit=realm-wrong-unit --uid=fixture --gid=realm-proxies "
            "spire-agent api fetch x509 -socketPath /run/spire/agent/public/api.sock -timeout 5s"
        )
        machine.succeed("systemctl stop realm-fixture.service")
        machine.succeed("mkdir -p /run/systemd/system/realm-fixture.service.d")
        machine.succeed("printf '[Service]\\nUser=imposter\\nGroup=imposter\\n' > /run/systemd/system/realm-fixture.service.d/user.conf")
        machine.succeed("systemctl daemon-reload")
        try:
            machine.fail("systemctl start realm-fixture.service")
            machine.succeed("test ! -e /run/realm-http-svid/svid.0.pem")
        finally:
            machine.succeed("rm /run/systemd/system/realm-fixture.service.d/user.conf")
            machine.succeed("systemctl daemon-reload")
        issue()

    with subtest("a banned node cannot reattest even with a valid HTTP proof"):
        machine.succeed("systemctl stop realm-fixture.service")
        machine.succeed(admin(f"agent ban -spiffeID {agent_id}"))
        fresh_agent()
        machine.succeed("systemctl start --no-block spire-agent.service")
        machine.wait_until_succeeds(
            "journalctl -u spire-server.service -o cat --no-pager | grep -F 'agent is banned'",
            timeout=60,
        )
        banned = json.loads(machine.succeed(admin(f"agent show -spiffeID {agent_id} -output json")))
        assert banned["banned"] is True, banned
        machine.fail("systemctl is-active --quiet spire-agent.service")
        machine.succeed("test ! -e /run/realm-http-svid/svid.0.pem")

    with subtest("eviction permits fresh HTTP enrollment with the same workload parent"):
        fresh_agent()
        machine.succeed(admin(f"agent evict -spiffeID {agent_id}"))
        machine.succeed("systemctl restart realm-spire-register.service")
        machine.succeed("systemctl start --no-block spire-agent.service")
        machine.wait_for_unit("spire-agent.service", timeout=90)
        assert entries(workload_id) == workloads
        assert entries(alias_id) == aliases
        issue()
        machine.succeed("test ! -e /var/lib/realm-spire/join-token")
  '';
}
