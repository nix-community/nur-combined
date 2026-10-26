{ nixpkgs }:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  inherit (pkgs) lib;
  secret = pkgs.writeText "dummy-immich.env" "DB_PASSWORD=dummy\n";
  photoRoute = import ../caddy/immich.nix;
  photoConfig = pkgs.writeText "immich-photo-routing.json" (
    builtins.toJSON {
      admin.disabled = true;
      apps.http.servers = {
        internal = {
          listen = [ "127.0.0.1:18081" ];
          automatic_https.disable = true;
          routes = [ (photoRoute { }) ];
        };
        public = {
          listen = [ "127.0.0.1:18080" ];
          automatic_https.disable = true;
          routes = [
            (photoRoute {
              basicAuthAccounts = [
                {
                  username = "fixture";
                  password = "$2a$14$QnBImTL.2HXKKWcx62rwEutSwD5rUj5TT98UFszOC.83pqQfjY66G";
                }
              ];
            })
          ];
        };
      };
    }
  );
  fixture = pkgs.writeText "immich-fixture.py" ''
    import http.server
    import json
    import os
    import pwd
    import socket
    import subprocess
    import sys
    import urllib.request

    mode = sys.argv[1]

    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            try:
                if mode == "ml":
                    result = pwd.getpwuid(os.getuid()).pw_name.encode()
                elif mode == "proxy":
                    with urllib.request.urlopen(os.environ["IMMICH_URL"] + self.path, timeout=10) as response:
                        result = response.read()
                else:
                    database = subprocess.check_output([
                        "psql", os.environ["DB_URL"], "-Atc",
                        "select current_user, current_database()",
                    ], text=True, timeout=10).strip()
                    with socket.create_connection(("127.0.0.1", 6379), timeout=10) as redis:
                        redis.sendall(b"*1\r\n$4\r\nPING\r\n")
                        pong = redis.recv(1024).decode().strip()
                    with urllib.request.urlopen("http://127.0.0.1:3003/", timeout=10) as response:
                        ml = response.read().decode()
                    result = json.dumps({"database": database, "redis": pong, "ml": ml}).encode()
            except Exception:
                self.send_error(503, "dependency unavailable")
                return
            self.send_response(200)
            self.send_header("X-Realm-Fixture", mode)
            self.send_header("X-Realm-Fixture-Path", self.path)
            self.end_headers()
            self.wfile.write(result)

        do_POST = do_GET

    port = int(os.environ["IPP_PORT"] if mode == "proxy" else os.environ["IMMICH_PORT"])
    http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
  '';
  executable =
    mode:
    pkgs.writeShellScriptBin "immich-${mode}-fixture" ''
      exec ${pkgs.python3}/bin/python3 ${fixture} ${mode}
    '';
in
pkgs.testers.runNixOSTest {
  name = "realm-immich";
  nodes.machine =
    { config, ... }:
    {
      imports = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/realm-observability.nix
        ../nixosModules/service-discovery.nix
        (import ../mod/realm-caddy-policy.nix).flake.modules.nixos.realm
        (import ../mod/immich.nix).flake.modules.nixos.immich
        (import ../mod/postgresql.nix).flake.modules.nixos.postgresql
        (import ../mod/realm-internet.nix).flake.modules.nixos.realm-internet
        {
          options.vaultix.secrets = lib.mkOption {
            type = lib.types.attrsOf lib.types.attrs;
            default = { };
          };
          config.vaultix.secrets.immich.path = toString secret;
        }
      ];
      networking.hostName = "machine";
      virtualisation.memorySize = 2048;
      environment.systemPackages = [
        pkgs.curl
        pkgs.util-linux
      ];
      services.immich.package = (executable "server") // {
        machine-learning = executable "ml";
      };
      services.immich-public-proxy.package = executable "proxy";
      services.prometheus.exporters.postgres.enable = lib.mkForce false;
      services.postgresql = {
        ensureDatabases = [ "immich" ];
        ensureUsers = [
          {
            name = "immich";
            ensureDBOwnership = true;
            ensureClauses.login = true;
          }
        ];
        settings = {
          shared_buffers = lib.mkForce "32MB";
          effective_cache_size = lib.mkForce "128MB";
          maintenance_work_mem = lib.mkForce "32MB";
          work_mem = lib.mkForce "4MB";
          huge_pages = lib.mkForce "off";
        };
      };

      realm = {
        enable = true;
        serviceDiscovery = {
          enable = true;
          address = "::1";
        };
        spire = {
          serverAddress = "::1";
          server = {
            enable = true;
            registrations.machine = lib.mapAttrs (
              _: entry:
              entry
              // {
                parentID = "spiffe://nyaw.xyz/agent/machine";
              }
            ) config.realm.spire.registrations;
          };
        };
        workloads = {
          caddy.spiffeID = config.realm.caddy.entrypointID;
          caddy.egress = {
            immich = {
              service = "immich";
              verifyID = "spiffe://nyaw.xyz/service/immich";
              localPort = 12283;
            };
            immich-public-proxy = {
              service = "immich-public-proxy";
              verifyID = "spiffe://nyaw.xyz/service/immich-public-proxy";
              localPort = 13001;
            };
          };
          imposter.egress = {
            immich = {
              service = "immich";
              verifyID = "spiffe://nyaw.xyz/service/immich";
              localPort = 12283;
            };
            postgresql = {
              service = "postgresql-autopeer";
              verifyID = "spiffe://nyaw.xyz/service/postgresql";
              localPort = 15432;
            };
            internet = {
              service = "internet-proxy";
              verifyID = "spiffe://nyaw.xyz/service/internet";
              localPort = 13128;
            };
          };
        };
      };
      systemd.services =
        lib.genAttrs [ "caddy" "imposter" ] (name: {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = name;
            Group = name;
            ExecStart =
              if name == "caddy" then
                "${pkgs.caddy}/bin/caddy run --config ${photoConfig}"
              else
                "${pkgs.coreutils}/bin/sleep infinity";
          };
        })
        // {
          postgresql.serviceConfig.ReadWritePaths = lib.mkForce [ ];
        };
    };
  testScript = ''
    import json

    def inside(unit, command):
        return f"nsenter -t $(systemctl show -p MainPID --value {unit}.service) -n {command}"

    machine.start()
    machine.wait_for_unit("spire-server.service")
    machine.wait_for_unit("realm-spire-register.service")
    machine.succeed("realm-enroll machine | realm-install-enrollment")
    machine.wait_for_unit("spire-agent.service")
    for unit in ["postgresql", "redis-immich", "immich-server", "immich-machine-learning", "immich-public-proxy", "caddy", "imposter"]:
        machine.wait_for_unit(f"{unit}.service")

    with subtest("authorized application dependencies and public proxy chain"):
        request = inside("caddy", "curl -fsS --max-time 20 http://127.0.0.1:13001/")
        machine.wait_until_succeeds(request, timeout=120)
        result = json.loads(machine.succeed(request))
        assert result == {"database": "immich|immich", "redis": "+PONG", "ml": "immich-ml"}, result
        machine.succeed(inside("caddy", "curl -fsS --max-time 20 http://127.0.0.1:12283/"))

    def photo(path, public=False, credentials=None, method="GET"):
        port = 18080 if public else 18081
        auth = f"--user {credentials}" if credentials else ""
        return inside("caddy", f"curl --path-as-is -sS --max-time 20 -X {method} {auth} -H 'Host: photo.nyaw.xyz' -D /tmp/photo-headers -o /tmp/photo-body -w '%{{http_code}}' 'http://127.0.0.1:{port}{path}'")

    def check_photo(path, backend, public=False, credentials=None, method="GET"):
        status = machine.succeed(photo(path, public, credentials, method)).strip()
        assert status == "200", (path, public, status)
        headers = machine.succeed("cat /tmp/photo-headers").lower()
        assert f"x-realm-fixture: {backend}" in headers, (path, headers)
        assert f"x-realm-fixture-path: {path}".lower() in headers, (path, headers)
        assert "www-authenticate:" not in headers, (path, headers)

    with subtest("internal photo main site has no Basic Auth and shares use the public proxy"):
        machine.wait_until_succeeds(photo("/") + " | grep -x 200", timeout=60)
        for path in ["/", "/auth/login", "/api/server/ping", "/share-other"]:
            check_photo(path, "server")
        for path in ["/share", "/share/", "/share/key", "/share/static/app.js", "/share/photo/key/id?size=thumbnail"]:
            check_photo(path, "proxy")
        check_photo("/share/unlock", "proxy", method="POST")

    with subtest("public photo main site requires Basic Auth while shares stay public"):
        for path in ["/", "/api/server/ping", "/auth/login", "/share-other", "/shares"]:
            assert machine.succeed(photo(path, public=True)).strip() == "401", path
            assert "www-authenticate: basic" in machine.succeed("cat /tmp/photo-headers").lower()
        for path in ["/share", "/share/", "/share/key", "/share/static/app.js", "/share/photo/key/id?size=thumbnail"]:
            check_photo(path, "proxy", public=True)
        check_photo("/share/unlock", "proxy", public=True, method="POST")
        assert machine.succeed(photo("/", public=True, credentials="fixture:wrong")).strip() == "401"
        check_photo("/", "server", public=True, credentials="fixture:realm-photo-fixture")
        check_photo("/api/server/ping", "server", public=True, credentials="fixture:realm-photo-fixture")
        for path in ["/share/../api/server/ping", "/share%2f..%2fapi/server/ping"]:
            status = machine.succeed(photo(path, public=True)).strip()
            assert status in ["200", "400", "401", "404"], (path, status)
            if status == "200":
                assert "x-realm-fixture: proxy" in machine.succeed("cat /tmp/photo-headers").lower(), path

    with subtest("local PostgreSQL peer identity cannot become another database role"):
        machine.succeed("runuser -u immich -- psql -h /run/postgresql -U immich -d immich -Atc 'select current_user' | grep -x immich")
        machine.fail("runuser -u nobody -- psql -h /run/postgresql -U immich -d immich -Atc 'select current_user'")
        machine.fail("runuser -u immich -- psql -h /run/postgresql -U postgres -d postgres -Atc 'select current_user'")
        machine.succeed("test ! -e /run/realm/immich/egress/postgresql.sock")
        machine.succeed("systemctl show -p PrivateNetwork --value postgresql.service | grep -x yes")
        assert machine.succeed("runuser -u postgres -- psql -Atc 'show listen_addresses'").strip() == ""

    with subtest("PostgreSQL TCP listeners are disabled"):
        for address in ["127.0.0.1", "::1"]:
            machine.fail(f"timeout 5 psql -h {address} -U immich -d immich -Atc 'select current_user'")
        machine.succeed("ip -6 address add fdcc::3/128 dev lo")
        machine.fail("PGPASSWORD=dummy psql -h fdcc::3 -U immich -d immich -Atc 'select current_user'")
        machine.fail(inside("immich-server", "timeout 5 psql -h fdcc::3 -U immich -d immich -Atc 'select current_user'"))

    with subtest("unauthorized SPIFFE client is rejected by both receivers"):
        machine.succeed("systemctl start realm-egress-imposter-immich.service realm-egress-imposter-postgresql.service realm-egress-imposter-internet.service")
        machine.wait_for_unit("realm-egress-imposter-immich.service")
        machine.wait_for_unit("realm-egress-imposter-postgresql.service")
        machine.fail(inside("imposter", "curl -fsS --max-time 5 http://127.0.0.1:12283/"))
        machine.fail(inside("imposter", "timeout 5 psql 'postgresql://immich@127.0.0.1:15432/immich?sslmode=disable' -Atc 'select current_user'"))

    with subtest("only ML identity may use its Internet proxy"):
        machine.succeed("ip address add 198.51.100.1/32 dev lo")
        machine.succeed("systemd-run --unit=public-fixture ${pkgs.python3}/bin/python3 -m http.server 80 --bind 198.51.100.1 --directory /etc")
        request = "curl --noproxy \"\" -fsS --max-time 10 --proxy http://127.0.0.1:13128 http://198.51.100.1/hostname"
        machine.wait_until_succeeds(inside("immich-machine-learning", request), timeout=30)
        machine.wait_for_unit("realm-egress-imposter-internet.service")
        machine.fail(inside("imposter", request))

    with subtest("private listeners and runtime sockets do not bypass the mesh"):
        for port in [2283, 3003, 3001]:
            machine.fail(f"curl -fsS --max-time 2 http://127.0.0.1:{port}/")
        pid = machine.succeed("systemctl show -p MainPID --value immich-server.service").strip()
        machine.succeed(f"nsenter -t {pid} -m ${pkgs.coreutils}/bin/test -S /run/postgresql/.s.PGSQL.5432")
        for path in ["/run/spire/agent/public/api.sock", "/run/redis-immich/redis.sock"]:
            machine.succeed(f"nsenter -t {pid} -m ${pkgs.coreutils}/bin/test ! -e {path}")
        machine.fail(inside("immich-server", "curl --noproxy '*' -fsS --max-time 2 http://198.51.100.1/hostname"))
  '';
}
