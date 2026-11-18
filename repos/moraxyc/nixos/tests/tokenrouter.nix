{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "tokenrouter";

  nodes = {
    machine = _: {
      imports = [ ../modules/services/web-apps/tokenrouter.nix ];

      services.tokenrouter = {
        enable = true;
        package = pkgs.tokenrouter;
        configureNginx = true;
        initialAdmin = {
          email = "admin@example.test";
          passwordFile = pkgs.writeText "tokenrouter-admin-password" "test-admin-password-123";
        };
      };
    };

    unix = _: {
      imports = [ ../modules/services/web-apps/tokenrouter.nix ];

      services.nginx.proxyResolveWhileRunning = true;

      services.tokenrouter = {
        enable = true;
        package = pkgs.tokenrouter;
        configureNginx = true;
        unixSocket = "/run/tokenrouter/tokenrouter.sock";
        initialAdmin = {
          email = "admin@example.test";
          passwordFile = pkgs.writeText "tokenrouter-admin-password" "test-admin-password-123";
        };
      };
    };
  };

  testScript = ''
    import json
    import re

    start_all()

    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-tokenrouter.service")
    machine.succeed("test -S /run/redis-tokenrouter/redis.sock")
    machine.fail("ss -tln | grep -q ':6379 '")
    machine.wait_for_unit("tokenrouter.socket")
    machine.wait_for_unit("tokenrouter.service")
    machine.wait_for_unit("nginx.service")
    machine.wait_for_open_port(8080)
    machine.wait_for_open_port(80)
    assert json.loads(machine.succeed("curl -fs http://127.0.0.1:8080/health"))["status"] == "ok"
    assert json.loads(machine.succeed("curl -fs http://127.0.0.1/health"))["status"] == "ok"
    html = machine.succeed("curl -fs http://127.0.0.1/")
    assert "tokenrouter" in html.lower(), html
    machine.succeed("test -s /var/lib/tokenrouter/.installed")
    machine.succeed("test -s /var/lib/tokenrouter/.secret-encryption-key")

    # Restart to verify declarative CONFIG_FILE startup after initial setup.
    machine.succeed("systemctl restart tokenrouter.service")
    machine.wait_for_unit("tokenrouter.service")
    machine.wait_for_open_port(8080)
    assert json.loads(machine.succeed("curl -fs http://127.0.0.1/health"))["status"] == "ok"
    machine.succeed(
        "curl -fs -X POST http://127.0.0.1/api/v1/auth/login "
        "-H 'Content-Type: application/json' "
        "-d '{\"email\":\"admin@example.test\",\"password\":\"test-admin-password-123\"}'"
    )

    unix.wait_for_unit("tokenrouter.socket")
    unix.wait_for_unit("tokenrouter.service")
    unix.wait_for_unit("nginx.service")
    unix.wait_for_open_port(80)
    unix.succeed("test -S /run/tokenrouter/tokenrouter.sock")
    unix.fail("ss -tln | grep -q ':8080 '")
    assert json.loads(
        unix.succeed("curl -fs --unix-socket /run/tokenrouter/tokenrouter.sock http://localhost/health")
    )["status"] == "ok"
    assert json.loads(unix.succeed("curl -fs http://127.0.0.1/health"))["status"] == "ok"

    unix_html = unix.succeed("curl -fs http://127.0.0.1/")
    match = re.search(r'src="(/assets/index-[^"]+\.js)"', unix_html)
    assert match, unix_html
    asset_headers = unix.succeed(f"curl -fsI http://127.0.0.1{match.group(1)}").lower()
    assert "javascript" in asset_headers, asset_headers

    unix.succeed("systemctl restart tokenrouter.service")
    unix.wait_for_unit("tokenrouter.service")
    assert json.loads(
        unix.succeed("curl -fs --unix-socket /run/tokenrouter/tokenrouter.sock http://localhost/health")
    )["status"] == "ok"
    assert json.loads(unix.succeed("curl -fs http://127.0.0.1/health"))["status"] == "ok"
    unix.succeed(
        "curl -fs -X POST http://127.0.0.1/api/v1/auth/login "
        "-H 'Content-Type: application/json' "
        "-d '{\"email\":\"admin@example.test\",\"password\":\"test-admin-password-123\"}'"
    )
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
