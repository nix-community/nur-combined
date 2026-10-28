{ nixpkgs }:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [ ];
  };
  inherit (pkgs) lib;
  dummyVault = pkgs.writeText "vault-fixture.env" ''
    DATABASE_URL=postgresql://vault:unused@127.0.0.1:5432/vaultwarden
    SMTP_HOST=box.nyaw.xyz
    SMTP_PORT=465
    SMTP_SECURITY=force_tls
    SMTP_FROM=vault@example.invalid
    SMTP_USERNAME=fixture
    SMTP_PASSWORD=fixture
  '';
  dummyNcps = pkgs.writeText "ncps-fixture.env" ''
    CACHE_STORAGE_S3_ACCESS_KEY_ID=fixture
    CACHE_STORAGE_S3_SECRET_ACCESS_KEY=fixture-secret
    CACHE_STORAGE_S3_USE_SSL=true
  '';
  dummyGrafana = pkgs.writeText "grafana-fixture.env" ''
    GF_DATABASE_URL=postgres://unused:dummy@localhost:1/nonexistent
    GF_SECURITY_ADMIN_USER=fixture
    GF_SECURITY_ADMIN_PASSWORD=fixture-password
  '';
  dummyLoki = pkgs.writeText "loki-fixture.json" (
    builtins.toJSON {
      auth_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3030;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9095;
      };
      common = {
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
      };
      schema_config.configs = [
        {
          from = "2023-01-05";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      ingester.wal.replay_memory_ceiling = "64MB";
    }
  );
  dependency = pkgs.writeText "realm-dependency-fixture.py" ''
    import http.server
    import hashlib
    import json
    import pathlib
    import socket
    import ssl
    import sys
    import urllib.parse

    tls = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    tls.load_cert_chain('/var/lib/fixture/cert.pem', '/var/lib/fixture/key.pem')
    if sys.argv[1] == 'smtp':
        listener = socket.socket()
        listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        listener.bind(('127.0.0.1', 465))
        listener.listen()
        while True:
            client, _ = listener.accept()
            try:
                with tls.wrap_socket(client, server_side=True) as stream:
                    stream.sendall(b'220 fixture ESMTP\r\n')
                    stream.recv(1024)
            except (OSError, ssl.SSLError):
                client.close()
    else:
        objects = {'/ncps/config/cache.key': pathlib.Path('/var/lib/fixture/cache.key').read_bytes()}
        class S3(http.server.BaseHTTPRequestHandler):
            def reply(self, body=b"", status=200, content_type='application/xml', head=False):
                self.send_response(status)
                self.send_header('content-type', content_type)
                self.send_header('content-length', str(len(body)))
                self.send_header('last-modified', 'Mon, 19 Oct 2026 00:00:00 GMT')
                self.send_header('etag', '"' + hashlib.md5(body).hexdigest() + '"')
                self.send_header('x-amz-bucket-region', 'ap-east-1')
                self.end_headers()
                if not head:
                    self.wfile.write(body)
            def do_HEAD(self):
                path = urllib.parse.urlsplit(self.path).path
                if path.endswith('/'):
                    self.reply(head=True)
                elif path in objects:
                    self.reply(objects[path], head=True)
                else:
                    self.reply(status=404, head=True)
            def do_PUT(self):
                path = urllib.parse.urlsplit(self.path).path
                objects[path] = self.rfile.read(int(self.headers.get('content-length', 0)))
                self.reply()
            def do_GET(self):
                url = urllib.parse.urlsplit(self.path)
                if url.path == '/.well-known/openid-configuration':
                    self.reply(json.dumps({'issuer': 'https://oidc.nyaw.xyz'}).encode(), content_type='application/json')
                elif 'versioning' in url.query:
                    self.reply(b'<VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"/>')
                elif 'location' in url.query:
                    self.reply(b'<LocationConstraint xmlns="http://s3.amazonaws.com/doc/2006-03-01/">ap-east-1</LocationConstraint>')
                elif url.path in objects:
                    self.reply(objects[url.path], content_type='application/octet-stream')
                elif url.path.endswith('/'):
                    self.reply(b'<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>fixture</Name><IsTruncated>false</IsTruncated></ListBucketResult>')
                else:
                    self.reply(status=404)
        server = http.server.ThreadingHTTPServer(('127.0.0.1', 18443), S3)
        server.socket = tls.wrap_socket(server.socket, server_side=True)
        server.serve_forever()
  '';
  spireFixture = import ./realm-spire-fixture.nix { inherit pkgs; };
in
pkgs.testers.runNixOSTest {
  name = "realm-extra-services";
  node.pkgsReadOnly = false;
  nodes.machine =
    { config, ... }:
    {
      imports = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-http.nix
        spireFixture.module
        ../nixosModules/realm-observability.nix
        ../nixosModules/service-discovery.nix
        (import ../mod/realm-caddy-policy.nix).flake.modules.nixos.realm
        ../nixosModules/ncps.nix
        ../nixosModules/stalwart.nix
        (import ../mod/jellyfin.nix).flake.modules.nixos.jellyfin
        (import ../mod/vaultwarden.nix).flake.modules.nixos.vaultwarden
        (import ../mod/forgejo.nix).flake.modules.nixos.forgejo
        (import ../mod/ncps.nix).flake.modules.nixos.ncps
        (import ../mod/postgresql.nix).flake.modules.nixos.postgresql
        (import ../mod/atuin.nix).flake.modules.nixos.atuin
        (import ../mod/grafana.nix).flake.modules.nixos.grafana
        (import ../mod/loki.nix).flake.modules.nixos.loki
        (import ../mod/stalwart.nix).flake.modules.nixos.stalwart
        (import ../mod/realm-internet.nix).flake.modules.nixos.realm-internet
        {
          options.vaultix.secrets = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { name, ... }:
                {
                  options = {
                    owner = lib.mkOption {
                      type = lib.types.str;
                      default = "root";
                    };
                    mode = lib.mkOption {
                      type = lib.types.str;
                      default = "400";
                    };
                    group = lib.mkOption {
                      type = lib.types.str;
                      default = "root";
                    };
                    path = lib.mkOption {
                      type = lib.types.str;
                      default = toString (
                        if name == "vault" then
                          dummyVault
                        else if name == "ncps" then
                          dummyNcps
                        else if name == "grafana" then
                          dummyGrafana
                        else if name == "loki" then
                          dummyLoki
                        else
                          pkgs.writeText "dummy-${name}" "fixture-secret"
                      );
                    };
                  };
                }
              )
            );
          };
        }
      ];
      networking.hostName = "machine";
      networking.hosts = {
        "fdcc::3" = [ "s3.nyaw.xyz" ];
        "fdcc::5" = [ "box.nyaw.xyz" ];
      };
      networking.nameservers = [ "127.0.0.53" ];
      virtualisation.memorySize = 4096;
      virtualisation.diskSize = 4096;
      virtualisation.cores = 2;
      environment.systemPackages = [
        pkgs.curl
        pkgs.util-linux
        pkgs.postgresql
        pkgs.openssl
        pkgs.dnsutils
      ];
      users.groups.rqbit = { };
      virtualisation.podman.enable = true;
      services.gitea-actions-runner.instances.default.enable = lib.mkForce false;
      services.ncps.analytics.reporting.enable = false;
      services.stalwart.package = pkgs.hello;
      services.prometheus.exporters.postgres.enable = lib.mkForce false;
      services.postgresql = {
        ensureDatabases = [
          "vaultwarden"
          "ncps"
          "grafana"
        ];
        ensureUsers = [
          { name = "vault"; }
          {
            name = "ncps";
            ensureDBOwnership = true;
          }
          {
            name = "grafana";
            ensureDBOwnership = true;
          }
        ];
        initialScript = pkgs.writeText "vault-owner.sql" "ALTER DATABASE vaultwarden OWNER TO vault;";
        settings = {
          shared_buffers = lib.mkForce "32MB";
          effective_cache_size = lib.mkForce "128MB";
          maintenance_work_mem = lib.mkForce "32MB";
          work_mem = lib.mkForce "4MB";
          huge_pages = lib.mkForce "off";
        };
      };
      services.dnsmasq = {
        enable = true;
        settings = {
          listen-address = "127.0.0.53";
          bind-interfaces = true;
          no-resolv = true;
          address = [ "/public.test/198.51.100.1" ];
        };
      };

      realm = {
        enable = true;
        identityCatalog = {
          machine = config.realm.localIdentities;
          fixture = {
            alloy = "spiffe://nyaw.xyz/service/alloy";
            artex = "spiffe://nyaw.xyz/service/artex";
          };
        };
        observability.enable = true;
        serviceDiscovery = {
          enable = true;
          address = "::1";
        };

        http.gateways.eihort = {
          hosts = [
            "s3.nyaw.xyz"
            "oidc.nyaw.xyz"
            "git.nyaw.xyz"
          ];
          service = "https-gateway";
          verifyID = config.realm.caddy.entrypointID;
        };
        workloads = {
          caddy = {
            spiffeID = config.realm.caddy.entrypointID;
            isolation.privateNetwork = false;
            ingress.https = {
              port = 19443;
              target = "127.0.0.1:18443";
              hostLoopback = true;
              service = "https-gateway";
              allowedIDs = [
                "spiffe://nyaw.xyz/service/forgejo"
                "spiffe://nyaw.xyz/service/ncps"
                "spiffe://nyaw.xyz/service/vaultwarden"
              ];
            };
            egress = lib.genAttrs [ "jellyfin" "vaultwarden" "forgejo" "grafana" "atuin" ] (name: {
              service = name;
              verifyID = "spiffe://nyaw.xyz/service/${name}";
            });
          };
          # These optional dependencies are not exercised by this fixture.
          grafana.egress.victoriametrics = {
            target = "[::1]:1";
            verifyID = "spiffe://nyaw.xyz/service/observability-machine";
          };
          loki.egress.s3 = {
            target = "[::1]:1";
            verifyID = "spiffe://nyaw.xyz/service/seaweedfs";
          };
          vmagent.egress.observation = {
            service = "observability-machine";
            verifyID = "spiffe://nyaw.xyz/service/observability-machine";
            localPort = 13190;
          };
          imposter.egress = {
            ncps = {
              service = "ncps";
              verifyID = "spiffe://nyaw.xyz/service/ncps";
              localPort = 18501;
            };
            smtp = {
              service = "smtp-submission";
              verifyID = "spiffe://nyaw.xyz/service/stalwart";
              localPort = 465;
            };
            postgresql = {
              service = "postgresql-autopeer";
              verifyID = "spiffe://nyaw.xyz/service/postgresql";
              localPort = 5432;
            };
          };
        };
      };
      systemd.tmpfiles.rules = [
        "d /var/lib/fixture 0755 root root -"
        "d /pool0/relation 0755 root root -"
      ];
      systemd.services = {
        caddy = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = "caddy";
            Group = "caddy";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
        };
        vmagent = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = "vmagent";
            Group = "vmagent";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
        };
        imposter = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = "imposter";
            Group = "imposter";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
        };
        seaweedfs = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
        };
        s3-fixture = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.python3}/bin/python3 ${dependency} s3";
            Restart = "on-failure";
          };
        };
        stalwart.serviceConfig.ExecStart = lib.mkForce "${pkgs.python3}/bin/python3 ${dependency} smtp";
        forgejo.environment.SSL_CERT_FILE = "/var/lib/fixture/cert.pem";
        ncps.environment.SSL_CERT_FILE = "/var/lib/fixture/cert.pem";
        vaultwarden.environment.SSL_CERT_FILE = "/var/lib/fixture/cert.pem";
      };
    };
  testScript = ''
    machine.start()
    machine.succeed("openssl req -x509 -newkey rsa:2048 -nodes -keyout /var/lib/fixture/key.pem -out /var/lib/fixture/cert.pem -days 1 -subj /CN=mesh-fixture -addext 'subjectAltName=DNS:s3.nyaw.xyz,DNS:box.nyaw.xyz,DNS:oidc.nyaw.xyz,DNS:git.nyaw.xyz'")
    machine.succeed("nix-store --generate-binary-cache-key cache.nyaw.xyz /var/lib/fixture/cache.key /var/lib/fixture/cache.pub")
    machine.succeed("chmod 644 /var/lib/fixture/key.pem /var/lib/fixture/cache.key")
    ${spireFixture.startAgent}
    machine.wait_for_unit("postgresql.service")
    machine.succeed("runuser -u postgres -- psql -c 'ALTER DATABASE vaultwarden OWNER TO vault'")
    machine.succeed("systemctl restart s3-fixture.service stalwart.service")
    def inside(unit, command):
        return f"nsenter -t $(systemctl show -p MainPID --value {unit}.service) -n {command}"
    def request(name, path):
        return f"runuser -u caddy -- curl --noproxy '*' -fsS --max-time 10 --unix-socket /run/realm/caddy/egress/{name}.sock http://localhost{path}"
    with subtest("real application startup and authenticated HTTP ingress"):
        for name, path in [("jellyfin", "/health"), ("vaultwarden", "/alive"), ("forgejo", "/api/v1/version"), ("grafana", "/api/health"), ("atuin", "/")]:
            machine.wait_until_succeeds(request(name, path), timeout=240)
    with subtest("Grafana ignores the legacy TCP database URL and Loki needs no host interfaces"):
        machine.succeed("systemctl is-active grafana.service loki.service")
        machine.wait_until_succeeds(inside("grafana", "curl -fsS --max-time 10 http://127.0.0.1:13030/ready"), timeout=60)
        machine.succeed("runuser -u postgres -- psql -c \"CREATE ROLE loopback_fixture LOGIN PASSWORD 'fixture-password'\"")
        machine.fail("psql postgresql://loopback_fixture:fixture-password@127.0.0.1/postgres?connect_timeout=2 -Atc 'select current_user'")
        machine.fail("psql postgresql://loopback_fixture:wrong@127.0.0.1/postgres -Atc 'select current_user'")
    with subtest("public Internet requests and FFmpeg use authenticated egress"):
        machine.succeed("ip address add 198.51.100.1/32 dev lo")
        machine.succeed("mkdir -p /tmp/public-fixture")
        machine.succeed("${pkgs.python3}/bin/python3 -c 'import wave; f=wave.open(\"/tmp/public-fixture/tone.wav\",\"wb\"); f.setnchannels(1); f.setsampwidth(2); f.setframerate(8000); f.writeframes(bytes(16000)); f.close()'")
        machine.succeed("systemd-run --unit=public-fixture ${pkgs.python3}/bin/python3 -m http.server 80 --bind 198.51.100.1 --directory /tmp/public-fixture")
        for unit in ["jellyfin", "vaultwarden", "forgejo", "ncps"]:
            machine.wait_until_succeeds(inside(unit, "curl --noproxy \"\" -fsS --max-time 10 --proxy http://127.0.0.1:13128 http://public.test/"), timeout=30)
        machine.succeed(inside("jellyfin", "env http_proxy=http://127.0.0.1:13128 ${pkgs.jellyfin-ffmpeg}/bin/ffprobe -v error -show_entries format=format_name -of default=noprint_wrappers=1 http://public.test/tone.wav | grep -x format_name=wav"))
    with subtest("workload-local host aliases preserve S3 and SMTP TLS identities"):
        for unit, host, port in [("forgejo", "s3.nyaw.xyz", 443), ("ncps", "s3.nyaw.xyz", 443), ("forgejo", "box.nyaw.xyz", 465), ("vaultwarden", "box.nyaw.xyz", 465)]:
            machine.succeed(f"nsenter -t $(systemctl show -p MainPID --value {unit}.service) -n -m ${pkgs.python3}/bin/python3 -c 'import socket; assert {{entry[4][0] for entry in socket.getaddrinfo(\"{host}\", {port}, type=socket.SOCK_STREAM)}} == {{\"127.0.0.1\"}}'")
            machine.wait_until_succeeds(f"nsenter -t $(systemctl show -p MainPID --value {unit}.service) -n -m sh -c 'printf \"QUIT\\r\\n\" | openssl s_client -connect {host}:{port} -servername {host} -verify_hostname {host} -verify_return_error -CAfile /var/lib/fixture/cert.pem >/dev/null'", timeout=45)
        machine.fail("getent hosts s3.nyaw.xyz | grep 127.0.0.1")
    with subtest("internal OIDC discovery bypasses the public proxy"):
        machine.wait_until_succeeds("nsenter -t $(systemctl show -p MainPID --value vaultwarden.service) -n -m env HTTPS_PROXY=http://127.0.0.1:13128 NO_PROXY=oidc.nyaw.xyz ${pkgs.python3}/bin/python3 -c 'import json, ssl, urllib.request; ctx = ssl.create_default_context(cafile=\"/var/lib/fixture/cert.pem\"); assert json.load(urllib.request.urlopen(\"https://oidc.nyaw.xyz/.well-known/openid-configuration\", context=ctx, timeout=10))[\"issuer\"] == \"https://oidc.nyaw.xyz\"'", timeout=45)
    with subtest("PostgreSQL peer identity is bound to the application route"):
        machine.succeed("nsenter -t $(systemctl show -p MainPID --value vaultwarden.service) -m runuser -u vaultwarden -- psql -h /run/postgresql -U vault -d vaultwarden -Atc 'select current_user' | grep -x vault")
        machine.fail("nsenter -t $(systemctl show -p MainPID --value vaultwarden.service) -m runuser -u vaultwarden -- psql -h /run/postgresql -U forgejo -d forgejo -Atc 'select current_user'")
        machine.fail(inside("imposter", "psql 'postgresql://vault@127.0.0.1:5432/vaultwarden?connect_timeout=5' -Atc 'select current_user'"))
    with subtest("unapproved callers cannot reach cache or SMTP ingress"):
        machine.fail(inside("imposter", "curl --noproxy '*' -fsS --max-time 5 http://127.0.0.1:18501/nix-cache-info"))
        machine.fail(inside("imposter", "curl --noproxy '*' -fsS --max-time 5 --cacert /var/lib/fixture/cert.pem --resolve box.nyaw.xyz:465:127.0.0.1 smtps://box.nyaw.xyz:465/"))
    with subtest("NCPS metrics remain available only through observation"):
        machine.wait_until_succeeds(inside("vmagent", "curl -fsS --max-time 10 http://127.0.0.1:13190/ncps/metrics"), timeout=45)
    with subtest("service ports and host runtime sockets are inaccessible"):
        for port in [8003, 8096, 36462, 8501]:
            machine.fail(f"curl --noproxy '*' -fsS --max-time 2 http://127.0.0.1:{port}/")
        for unit in ["jellyfin", "vaultwarden", "forgejo", "ncps"]:
            machine.succeed(f"nsenter -t $(systemctl show -p MainPID --value {unit}.service) -m test ! -e /run/spire/agent/public/api.sock")
            machine.succeed(f"nsenter -t $(systemctl show -p MainPID --value {unit}.service) -n ip -o link show | wc -l | grep -x 1")
            machine.fail(inside(unit, "curl --noproxy '*' -fsS --max-time 2 http://198.51.100.1/"))
  '';
}
