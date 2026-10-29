{
  nixpkgs,
  fixture ? null,
  extraModule ? { },
  extraTestScript ? "",
  testName ? "realm-workload-networking",
  internetTests ? true,
}:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [ ];
  };
  spireFixture =
    if fixture == null then import ./realm-spire-fixture.nix { inherit pkgs; } else fixture;
in
pkgs.testers.runNixOSTest {
  name = testName;
  nodes.machine =
    { config, ... }:
    {
      imports = [
        ../nixosModules/realm-workloads.nix
        spireFixture.module
        extraModule
        ../nixosModules/realm-observability.nix
        ../nixosModules/service-discovery.nix
        (import ../mod/realm-internet.nix).flake.modules.nixos.realm-internet
      ];
      virtualisation.memorySize = 2048;
      networking.hostName = "machine";
      environment.systemPackages = [
        pkgs.curl
        pkgs.util-linux
        pkgs.postgresql
        pkgs.openssl
        pkgs.dnsutils
        pkgs.python3
        pkgs.spire
      ];
      realm.observability = {
        enable = true;
        endpoints = {
          fixture = {
            port = 18081;
            publicProxyPort = 18082;
          };
          business = {
            port = 18081;
            businessProxyPort = 18084;
            businessAllowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
          };
          prober = {
            port = 18083;
            kind = "probe";
            path = "/probe";
            probes = [
              {
                module = "icmp";
                target = "198.51.100.1";
              }
              # A URL target is percent-encoded in the query, which the gateway
              # must accept: only the path is subject to the slash checks.
              {
                module = "http_2xx";
                target = "https://example.invalid";
              }
            ];
          };
        };
      };
      services.dnsmasq = {
        enable = true;
        settings = {
          listen-address = "127.0.0.1";
          bind-interfaces = true;
          no-resolv = true;
          addn-hosts = "/run/realm-dns-hosts";
          local-ttl = 1;
          log-queries = true;
          address = [
            "/public.test/198.51.100.1"
            "/public-v6.test/2001:db8::1"
            "/private.test/127.0.0.1"
            "/mesh.test/fdcc::3"
            "/ygg.test/200::1"
          ];
        };
      };
      environment.etc."realm-dns-hosts".text = ''
        198.51.100.1 transition.test mixed.test
        127.0.0.1 mixed.test
      '';
      environment.etc."realm-internet-fixture.py".text = ''
        import http.server
        import pathlib
        import socket
        import ssl
        import threading

        logs = pathlib.Path("/run/realm-internet-fixture")
        logs.mkdir(exist_ok=True)
        for name in ["connections", "private-connections"]:
            (logs / name).touch()
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain("/tmp/public.crt", "/tmp/public.key")

        class Handler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                body = b"realm Internet fixture\n"
                self.send_response(200)
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

        class Server(http.server.ThreadingHTTPServer):
            daemon_threads = True

            def get_request(self):
                connection, peer = super().get_request()
                address, port = connection.getsockname()[:2]
                entry = f"{address} {port}\n"
                with (logs / "connections").open("a") as log:
                    log.write(entry)
                if address not in ["198.51.100.1", "2001:db8::1"]:
                    with (logs / "private-connections").open("a") as log:
                        log.write(entry)
                connection.settimeout(10)
                if connection.recv(1, socket.MSG_PEEK) == b"\x16":
                    connection = context.wrap_socket(connection, server_side=True)
                return connection, peer

        class Server6(Server):
            address_family = socket.AF_INET6

            def server_bind(self):
                self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
                super().server_bind()

        for server_type, address in [(Server, "0.0.0.0"), (Server6, "::")]:
            for port in [80, 443, 8448, 8443]:
                server = server_type((address, port), Handler)
                threading.Thread(target=server.serve_forever, daemon=True).start()
        threading.Event().wait()
      '';
      services.postgresql = {
        enable = true;
        authentication = pkgs.lib.mkForce "local sender sender peer map=realm\nlocal all all peer";
        identMap = "realm realm-pg-sender sender";
        ensureDatabases = [ "sender" ];
        ensureUsers = [
          {
            name = "sender";
            ensureDBOwnership = true;
          }
        ];
      };

      realm = {
        enable = true;
        serviceDiscovery = {
          enable = true;
          address = "::1";
        };

        spire.registrations.vm-status = {
          spiffeID = "spiffe://nyaw.xyz/observer/identity/machine";
          selectors = [ "unix:uid:0" ];
        };
        spire.registrations.vm-status-imposter = {
          spiffeID = "spiffe://nyaw.xyz/test/status-imposter";
          selectors = [ "unix:uid:0" ];
        };
        workloads = {
          vmagent.egress.observation = {
            service = "observability-machine";
            verifyID = "spiffe://nyaw.xyz/service/observability-machine";
            localPort = 13190;
          };
          sender.socksProxy.enable = true;
          synapse.egress.internet = {
            service = "internet-proxy";
            verifyID = "spiffe://nyaw.xyz/service/internet";
            localPort = 13128;
          };
          sender.egress.observation = {
            service = "observability-machine";
            verifyID = "spiffe://nyaw.xyz/service/observability-machine";
            localPort = 13190;
          };
          sender.egress.business = {
            service = "business-machine";
            verifyID = "spiffe://nyaw.xyz/service/observability-machine";
            localPort = 13191;
          };
          internet.ingress.http.allowedIDs = pkgs.lib.mkForce [
            "spiffe://nyaw.xyz/service/sender"
            "spiffe://nyaw.xyz/service/synapse"
          ];
          sender.egress = {
            internet = {
              service = "internet-proxy";
              verifyID = "spiffe://nyaw.xyz/service/internet";
              localPort = 13128;
            };
            receiver = {
              service = "receiver";
              verifyID = "spiffe://nyaw.xyz/service/receiver";
              localPort = 13100;
            };
            postgresql = {
              service = "postgresql-sender";
              verifyID = "spiffe://nyaw.xyz/service/postgresql";
              localPort = 15432;
            };
          };
          postgresql = {
            user = "postgres";
            group = "postgres";
            isolation.runtimePaths = [ "/run/postgresql" ];
            ingress.sender = {
              port = 19432;
              target = "unix:/run/postgresql/.s.PGSQL.5432";
              service = "postgresql-sender";
              backendUser = "realm-pg-sender";
              allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
            };
          };
          imposter.egress.receiver = {
            service = "receiver";
            verifyID = "spiffe://nyaw.xyz/service/receiver";
            localPort = 13100;
          };
          imposter.egress.business = {
            service = "business-machine";
            verifyID = "spiffe://nyaw.xyz/service/observability-machine";
            localPort = 13192;
          };
          imposter.egress.internet = {
            service = "internet-proxy";
            verifyID = "spiffe://nyaw.xyz/service/internet";
            localPort = 13128;
          };
          wrong-server.egress.receiver = {
            service = "receiver";
            verifyID = "spiffe://nyaw.xyz/service/not-receiver";
            target = "[::1]:19429";
            localPort = 13100;
          };
          wrong-server.egress.internet = {
            service = "internet-proxy";
            verifyID = "spiffe://nyaw.xyz/service/not-internet";
            target = "[::1]:19328";
            localPort = 13128;
          };
          receiver.ingress.http = {
            port = 19429;
            target = "127.0.0.1:3030";
            privateLoopback = true;
            service = "receiver";
            allowedIDs = [
              "spiffe://nyaw.xyz/service/sender"
              "spiffe://nyaw.xyz/service/wrong-server"
            ];
          };
        };
      };
      users.groups = {
        sender = { };
        synapse = { };
        receiver = { };
        imposter = { };
        wrong-server = { };
        vmagent = { };
        realm-pg = { };
      };
      users.users =
        pkgs.lib.genAttrs
          [
            "synapse"
            "sender"
            "receiver"
            "imposter"
            "wrong-server"
            "vmagent"
          ]
          (name: {
            isSystemUser = true;
            group = name;
          })
        // {
          realm-pg-sender = {
            isSystemUser = true;
            group = "realm-pg";
          };
        };
      systemd.services =
        (pkgs.lib.genAttrs [ "synapse" "sender" "imposter" "wrong-server" "vmagent" ] (name: {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = name;
            Group = name;
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
        }))
        // {
          # The reconciler sets a one-hour TTL. Shorten this fixture entry
          # before the agent issues the gateway's first SVID.
          realm-spire-register.postStart = ''
            entry_id=$(${pkgs.spire}/bin/spire-server entry show \
              -socketPath /run/spire/server/private/api.sock \
              -spiffeID ${config.realm.workloads.internet.spiffeID} -output json \
              | ${pkgs.jq}/bin/jq -er '.entries[0].id')
            ${pkgs.spire}/bin/spire-server entry update \
              -socketPath /run/spire/server/private/api.sock \
              -entryID "$entry_id" \
              -parentID spiffe://nyaw.xyz/agent/machine \
              -spiffeID ${config.realm.workloads.internet.spiffeID} \
              -selector systemd:id:realm-internet.service \
              -selector unix:user:${config.realm.workloads.internet.user} \
              -x509SVIDTTL 30
          '';
          dnsmasq.preStart = ''
            cp /etc/realm-dns-hosts /run/realm-dns-hosts
          '';
          observation-fixture = {
            wantedBy = [ "multi-user.target" ];
            serviceConfig.ExecStart = "${pkgs.python3}/bin/python3 ${pkgs.writeText "observation-fixture.py" ''
              import http.server, threading
              class Handler(http.server.BaseHTTPRequestHandler):
                  def do_GET(self):
                      self.send_response(200)
                      self.end_headers()
                      self.wfile.write(("fixture_metric 1\\n" + self.path).encode())
              for port in [18081, 18083]:
                  server = http.server.HTTPServer(("0.0.0.0", port), Handler)
                  threading.Thread(target=server.serve_forever, daemon=True).start()
              threading.Event().wait()
            ''}";
          };
          receiver = {
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              User = "receiver";
              Group = "receiver";
              ExecStart = "${pkgs.python3}/bin/python3 ${pkgs.writeText "realm-receiver.py" ''
                import http.server

                class Handler(http.server.SimpleHTTPRequestHandler):
                    def do_POST(self):
                        body = self.rfile.read(int(self.headers["Content-Length"]))
                        self.send_response(200)
                        self.send_header("Content-Length", str(len(body)))
                        self.end_headers()
                        self.wfile.write(body)

                http.server.ThreadingHTTPServer(("127.0.0.1", 3030), Handler).serve_forever()
              ''}";
              WorkingDirectory = "/etc";
            };
          };
        };
    };
  testScript = ''
    machine.start()
    ${spireFixture.startAgent}
    machine.wait_for_unit("receiver.service")
    machine.wait_for_unit("coredns.service")
    machine.succeed("dig @127.0.0.1 -p 8600 +short SRV receiver.svc.mesh.nyaw.xyz | grep -q '19429 receiver.machine.svc.mesh.nyaw.xyz.'")

    def probe(name):
        return f"nsenter -t $(systemctl show -p MainPID --value {name}.service) -n curl -fsS --max-time 10 http://127.0.0.1:13100/hostname"

    with subtest("CoreDNS publication and direct authorized mTLS"):
        machine.wait_until_succeeds(probe("sender"), timeout=90)
    with subtest("unauthorized client identity"):
        machine.fail(probe("imposter"))
    with subtest("wrong server identity"):
        machine.fail(probe("wrong-server"))
    with subtest("PostgreSQL peer authentication survives the tunnel"):
        machine.wait_until_succeeds("nsenter -t $(systemctl show -p MainPID --value sender.service) -n psql postgresql://sender@127.0.0.1:15432/sender -Atc 'select current_user' | grep -x sender", timeout=30)
    def internet(url, name="sender", tunnel=False, flags="-f"):
        tunnel_flag = "--proxytunnel" if tunnel else ""
        return (
            f"nsenter -t $(systemctl show -p MainPID --value {name}.service) -n "
            f"curl --noproxy \"\" -gsS --max-time 10 {flags} {tunnel_flag} "
            f"--proxy http://127.0.0.1:13128 {url}"
        )

    def connections(private=False):
        name = "private-connections" if private else "connections"
        return machine.succeed(f"cat /run/realm-internet-fixture/{name}")

    def denied(url, tunnel=False, statuses=("403",), name="sender"):
        before = connections()
        code = "%{http_connect}" if tunnel else "%{http_code}"
        status, output = machine.execute(internet(url, name, tunnel, f"--no-show-error -o /dev/null -w '{code}'"))
        # curl versions report rejected CONNECT requests as exit 7 or 56.
        # The required HTTP status and unchanged backend log prove rejection.
        assert status in ([0, 7, 56] if tunnel else [0]), (url, status, output)
        assert output.strip() in statuses, (url, output)
        assert connections() == before, f"Rejected request reached the backend: {url}"

  ''
  + pkgs.lib.optionalString internetTests ''
    with subtest("authenticated Internet proxy permits public destinations"):
        for address in ["198.51.100.1/32", "10.1.2.3/32", "100.64.0.1/32", "169.254.1.1/32", "172.16.0.1/32", "192.168.1.1/32"]:
            machine.succeed(f"ip address add {address} dev lo")
        for address in ["2001:db8::1/128", "fdcc::3/128", "200::1/128"]:
            machine.succeed(f"ip -6 address add {address} dev lo")
        machine.succeed("openssl req -x509 -newkey rsa:2048 -nodes -keyout /tmp/public.key -out /tmp/public.crt -days 1 -subj /CN=public.test -addext subjectAltName=DNS:public.test")
        machine.succeed("cp /tmp/public.crt /etc/public-fixture.crt")
        machine.succeed("systemd-run --unit=internet-fixture ${pkgs.python3}/bin/python3 /etc/realm-internet-fixture.py")
        machine.wait_until_succeeds(internet("http://198.51.100.1/hostname"), timeout=30)
        machine.succeed(internet("http://public.test/hostname"))
        machine.succeed(internet("http://public.test:443/hostname"))
        assert connections(), "The fixture must record successful connections"
        assert connections(private=True) == ""
    with subtest("Internet proxy requires an authorized SPIFFE client and the expected server identity"):
        before = connections()
        for name in ["imposter", "wrong-server"]:
            machine.fail(internet("http://198.51.100.1/hostname", name=name))
        machine.fail("curl --noproxy '*' -skf --max-time 3 https://[::1]:19328/")
        assert connections() == before
        machine.succeed(internet("http://public.test/hostname"))
    with subtest("CONNECT passes application TLS unchanged"):
        machine.wait_until_succeeds(internet("https://public.test/", flags="--cacert /etc/public-fixture.crt -f"), timeout=30)
    with subtest("raw HTTP/1.0 CONNECT preserves application TLS"):
        import shlex
        raw_connect = ${builtins.toJSON ''
          import socket, ssl
          with socket.create_connection(("127.0.0.1", 13128), timeout=10) as connection:
              connection.sendall(b"CONNECT public.test:443 HTTP/1.0\r\n\r\n")
              response = b""
              while not response.endswith(b"\r\n\r\n"):
                  chunk = connection.recv(1)
                  assert chunk, response
                  response += chunk
                  assert len(response) < 16384, response
              assert response.split(b"\r\n", 1)[0].split()[1] == b"200", response
              context = ssl.create_default_context(cafile="/etc/public-fixture.crt")
              with context.wrap_socket(connection, server_hostname="public.test") as tls:
                  tls.sendall(b"GET / HTTP/1.0\r\nHost: public.test\r\n\r\n")
                  body = b""
                  while True:
                      chunk = tls.recv(4096)
                      if not chunk:
                          break
                      body += chunk
                  assert b"realm Internet fixture" in body, body
        ''};
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value sender.service) -n python3 -c " + shlex.quote(raw_connect))
    with subtest("native SPIFFE rotates the gateway certificate without a process restart"):
        process = "systemctl show realm-internet.service -p MainPID -p NRestarts"
        before = machine.succeed(process)
        # The server sends its certificate before it rejects the missing client SVID.
        serial_command = "(timeout 5 openssl s_client -connect '[::1]:19328' -showcerts </dev/null 2>/dev/null || true) | openssl x509 -noout -serial"
        serial = machine.succeed(serial_command).strip()
        assert serial.startswith("serial=") and len(serial) > len("serial="), serial
        machine.wait_until_succeeds(
            f"serial=$( {serial_command} ); test -n \"$serial\" && test \"$serial\" != '{serial}'",
            timeout=90,
        )
        assert machine.succeed(process) == before
        machine.succeed(internet("http://public.test/hostname"))
        machine.succeed(internet("https://public.test/", flags="--cacert /etc/public-fixture.crt -f"))
    with subtest("SOCKS clients traverse the authenticated HTTP gateway"):
        machine.wait_until_succeeds("nsenter -t $(systemctl show -p MainPID --value sender.service) -n curl --noproxy \"\" --cacert /etc/public-fixture.crt -fsS --max-time 10 --socks5-hostname 127.0.0.1:11080 https://public.test/", timeout=30)
        before = connections()
        machine.fail("nsenter -t $(systemctl show -p MainPID --value sender.service) -n curl --noproxy \"\" -ksf --max-time 5 --socks5-hostname 127.0.0.1:11080 https://private.test/")
        assert connections() == before
    with subtest("only Synapse may use federation port 8448"):
        machine.wait_until_succeeds(internet("http://public.test:8448/", name="synapse", tunnel=True), timeout=30)
        denied("http://public.test:8448/", tunnel=True)
        for name in ["sender", "synapse"]:
            denied("http://public.test:8448/", name=name)
    with subtest("public IPv6 destination"):
        machine.wait_until_succeeds(internet("http://public-v6.test/hostname"), timeout=30)
        machine.succeed(internet("http://[2001:db8::1]/hostname"))
    with subtest("mixed DNS answers select a public destination"):
        answers = machine.succeed("dig @127.0.0.1 +short A mixed.test").splitlines()
        assert set(answers) == {"198.51.100.1", "127.0.0.1"}, answers
        before = connections(private=True)
        for _ in range(6):
            machine.succeed(internet("http://mixed.test/hostname"))
        assert connections(private=True) == before
    with subtest("a cached public DNS name cannot reach a private address after refresh"):
        machine.succeed(internet("http://transition.test/hostname"))
        before = connections(private=True)
        machine.succeed("printf '127.0.0.1 transition.test\\n198.51.100.1 mixed.test\\n127.0.0.1 mixed.test\\n' > /run/realm-dns-hosts")
        machine.succeed("systemctl kill --signal=HUP dnsmasq.service")
        # Requests trigger fresh resolution; wait until the changed answer is visible.
        machine.succeed(internet("http://transition.test/hostname", flags="-o /dev/null"))
        machine.wait_until_succeeds("journalctl -u dnsmasq.service -o cat --no-pager | grep -F 'transition.test is 127.0.0.1'", timeout=90)
        assert machine.succeed("dig @127.0.0.1 +short A transition.test").strip() == "127.0.0.1"
        # A failed refresh may retain the previous public address.
        for _ in range(6):
            result = machine.succeed(internet("http://transition.test/hostname", flags="-o /dev/null -w '%{http_code}'"))
            assert result in ["200", "403", "503"], result
        assert connections(private=True) == before
        machine.succeed(internet("http://public.test/hostname"))
    with subtest("Internet proxy denies private literal addresses"):
        for destination in ["127.0.0.1", "10.1.2.3", "100.64.0.1", "169.254.1.1", "172.16.0.1", "192.168.1.1", "[::1]", "[fdcc::3]", "[200::1]", "[::ffff:127.0.0.1]", "[::ffff:10.1.2.3]"]:
            denied(f"http://{destination}/", statuses=("403", "503"))
            denied(f"http://{destination}:443/", tunnel=True, statuses=("403", "503"))
    with subtest("Internet proxy denies private DNS answers"):
        for destination in ["private.test", "mesh.test", "ygg.test"]:
            # DNS filtering can remove every address before upstream RBAC runs.
            denied(f"http://{destination}/", statuses=("403", "503"))
            denied(f"http://{destination}:443/", tunnel=True, statuses=("403", "503"))
    with subtest("CONNECT destination and port restrictions"):
        for name in ["sender", "synapse"]:
            for port in [80, 8443]:
                denied(f"http://public.test:{port}/", tunnel=True, name=name)
            denied("http://public.test:8443/", name=name)
  ''
  + ''
    with subtest("gateway exposes only loopback core metrics and authenticated status"):
        machine.wait_until_succeeds("curl --noproxy '*' -fsS http://127.0.0.1:19329/metrics | grep '^caddy_'", timeout=30)
        for path in ["/config/", "/debug/pprof/", "/stop", "/load"]:
            machine.fail(f"curl --noproxy '*' -fsS --max-time 3 http://127.0.0.1:19329{path}")
        machine.fail("curl --noproxy '*' -gfsS --max-time 3 http://[::1]:19329/metrics")
        machine.fail("curl --noproxy '*' -ksf --max-time 3 https://127.0.0.1:19330/")
        machine.succeed("mkdir -p /run/status-svid; spire-agent api fetch x509 -socketPath /run/spire/agent/public/api.sock -write /run/status-svid")
        machine.succeed("for cert in /run/status-svid/svid.*.pem; do if openssl x509 -in \"$cert\" -noout -ext subjectAltName | grep -q 'URI:spiffe://nyaw.xyz/observer/identity/machine'; then cp \"$cert\" /run/status.crt; cp \"$(echo \"$cert\" | cut -d. -f1,2).key\" /run/status.key; fi; done; test -s /run/status.key")
        machine.succeed("for cert in /run/status-svid/svid.*.pem; do if openssl x509 -in \"$cert\" -noout -ext subjectAltName | grep -q 'URI:spiffe://nyaw.xyz/test/status-imposter'; then cp \"$cert\" /run/status-imposter.crt; cp \"$(echo \"$cert\" | cut -d. -f1,2).key\" /run/status-imposter.key; fi; done; test -s /run/status-imposter.key")
        machine.fail("curl --noproxy '*' -ksf --max-time 5 --cert /run/status-imposter.crt --key /run/status-imposter.key https://127.0.0.1:19330/")
        status_probe = "curl --noproxy '*' -ksS --max-time 5 --cert /run/status.crt --key /run/status.key"
        assert machine.succeed(status_probe + " -o /dev/null -w '%{http_code}' https://127.0.0.1:19330/") == "204"
        machine.fail(status_probe + " -f --tls-max 1.2 https://127.0.0.1:19330/")
        machine.fail(status_probe + " -f https://127.0.0.1:19330/config/")
    with subtest("native ingress replaces the gateway ghostunnel"):
        machine.fail("systemctl cat realm-ingress-internet-http.service")
        machine.fail("ss -lnt | grep -E '127.0.0.1:3128\\b'")
    def observe(path, flags="", name="vmagent"):
        return f"nsenter -t $(systemctl show -p MainPID --value {name}.service) -n curl --path-as-is -sS --max-time 5 {flags} 'http://127.0.0.1:13190{path}'"

    with subtest("only the observation identity can read metrics"):
        machine.wait_until_succeeds(observe("/fixture/metrics", "-f"), timeout=30)
        machine.fail(observe("/fixture/metrics", "-f", "sender"))
        machine.succeed(observe("/fixture/metrics", "-f") + " | grep -F /metrics")
        machine.succeed(observe("/internet-gateway/metrics", "-f") + " | grep '^caddy_'")
        machine.fail(observe("/internet-gateway/metrics", "-f", "sender"))
    with subtest("observation ingress cannot access business or debugging endpoints"):
        for path in ["/", "/debug/pprof", "/fixture/metrics?debug=1", "/fixture/../debug/pprof", "/fixture/%2fdebug/pprof"]:
            result = machine.succeed(observe(path, "-o /dev/null -w '%{http_code}'"))
            assert result in ["400", "403", "404"], (path, result)
        assert machine.succeed(observe("/fixture/metrics", "-X POST -o /dev/null -w '%{http_code}'")) == "403"
    with subtest("probe requires an exact module and target without duplicate or extra parameters"):
        machine.succeed(observe("/prober/probe?module=icmp&target=198.51.100.1", "-f"))
        machine.succeed(observe("/prober/probe?target=198.51.100.1&module=icmp", "-f"))
        machine.succeed(observe("/prober/probe?module=http_2xx&target=https%3A%2F%2Fexample.invalid", "-f"))
        for query in ["module=icmp&target=127.0.0.1", "module=unknown&target=198.51.100.1", "module=icmp&target=198.51.100.1&target=127.0.0.1", "module=icmp&target=198.51.100.1&%74arget=127.0.0.1", "module=icmp&target=198.51.100.1&debug=true", "module=icmp&target=198.51.100.1&module=http_2xx"]:
            assert machine.succeed(observe("/prober/probe?" + query, "-o /dev/null -w '%{http_code}'")) == "403", query
    with subtest("the plaintext business port keeps its path restrictions"):
        machine.succeed("curl --noproxy '*' -gf --max-time 5 http://[::1]:18082/index")
        for path in ["/metrics", "/metrics?debug=1", "/metrics/", "/%6detrics", "//metrics", "/debug/pprof"]:
            assert machine.succeed(f"curl --noproxy '*' -gsS --max-time 5 -o /dev/null -w '%{{http_code}}' 'http://[::1]:18082{path}'") == "403", path
    def business(path, flags="", name="sender", port=13191):
        return f"nsenter -t $(systemctl show -p MainPID --value {name}.service) -n curl --path-as-is -sS --max-time 5 {flags} 'http://127.0.0.1:{port}{path}'"

    with subtest("the authenticated business API excludes observation and debugging endpoints"):
        machine.wait_until_succeeds(business("/index", "-f"), timeout=90)
        machine.succeed(business("/index", "-f") + " | grep -F /index")
        machine.succeed(business("/api/v1/query?query=up", "-f"))
        for path in ["/metrics", "/metrics/extra", "/debug/pprof", "/metrics?format=prometheus", "/a/../metrics", "//metrics"]:
            assert machine.succeed(business(path, "--path-as-is -o /dev/null -w '%{http_code}'")) == "403"
        assert machine.succeed(business("/metrics%2fextra", "--path-as-is -o /dev/null -w '%{http_code}'")) == "400"
        assert machine.succeed(business("/index", "-X POST -o /dev/null -w '%{http_code}'")) in ["200", "405", "501"]
    with subtest("the authenticated API listener rejects unauthorized identities"):
        machine.fail(business("/index", "-f", "imposter", 13192))
        machine.fail("curl --noproxy '*' -skf --max-time 3 https://[::1]:18084/")
    with subtest("raw backend ports remain blocked if a backend binds all interfaces"):
        machine.succeed("ip netns add observation-untrusted")
        machine.succeed("ip link add obs-host type veth peer name obs-client")
        machine.succeed("ip link set obs-client netns observation-untrusted")
        machine.succeed("ip addr add 192.0.2.1/30 dev obs-host && ip link set obs-host up")
        machine.succeed("ip -n observation-untrusted addr add 192.0.2.2/30 dev obs-client && ip -n observation-untrusted link set obs-client up")
        machine.fail("ip netns exec observation-untrusted curl -sf --max-time 2 http://192.0.2.1:18083/probe")
        for port, scheme, path in [(19329, "http", "/metrics"), (19330, "https", "/")]:
            machine.fail(f"ip netns exec observation-untrusted curl --noproxy '*' -ksf --max-time 2 {scheme}://192.0.2.1:{port}{path}")
    with subtest("raw backend is private"):
        machine.fail("curl -sf --max-time 2 http://127.0.0.1:3030/hostname")
    with subtest("host sockets are hidden from workload"):
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value sender.service) -m ${pkgs.coreutils}/bin/test ! -e /run/spire/agent/public/api.sock")
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value sender.service) -m ${pkgs.coreutils}/bin/test ! -e /run/realm/imposter/egress/receiver.sock")
    with subtest("workload keeps a private writable /tmp"):
        # Joining realm-net-<name> suppresses PrivateTmp's tmpfs, so the module
        # mounts one explicitly. Host files must stay invisible, and a workload
        # that spools payloads into /tmp must still be able to write there.
        machine.succeed("touch /tmp/host-only-marker")
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value sender.service) -m ${pkgs.coreutils}/bin/test ! -e /tmp/host-only-marker")
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value sender.service) -m ${pkgs.coreutils}/bin/touch /tmp/workload-marker")
    with subtest("workload cannot connect directly to ingress"):
        machine.fail("nsenter -t $(systemctl show -p MainPID --value sender.service) -n curl -skf --max-time 2 https://[::1]:19429/")
    def payload():
        machine.succeed("dd if=/dev/urandom of=/tmp/realm-payload.bin bs=1M count=1")
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value sender.service) -n curl -fsS --max-time 15 --data-binary @/tmp/realm-payload.bin http://127.0.0.1:13100/echo -o /tmp/realm-response.bin")
        machine.succeed("cmp /tmp/realm-payload.bin /tmp/realm-response.bin")

    with subtest("binary request and response cross the local adapters and mTLS proxies"):
        payload()
    with subtest("proxy restart preserves socket activation and workload identity"):
        machine.succeed("systemctl restart realm-local-sender-receiver.service realm-egress-sender-receiver.service realm-ingress-receiver-http.service realm-backend-receiver-http.service")
        machine.succeed(probe("sender"))
        payload()
        machine.fail(probe("imposter"))
        machine.fail(probe("wrong-server"))
    with subtest("idempotent registration synchronization"):
        machine.succeed("systemctl restart realm-spire-register.service")
        machine.succeed(probe("sender"))
    ${extraTestScript}
  '';
}
