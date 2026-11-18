{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "tokenrouter";

  nodes.machine = _: {
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

  testScript = ''
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-tokenrouter.service")
    machine.succeed("test -S /run/redis-tokenrouter/redis.sock")
    machine.fail("ss -tln | grep -q ':6379 '")
    machine.wait_for_unit("tokenrouter.service")
    machine.wait_for_unit("nginx.service")
    machine.wait_for_open_port(8080)
    machine.wait_for_open_port(80)
    machine.succeed("curl -fs http://127.0.0.1:8080/health")
    machine.succeed("curl -fs http://127.0.0.1/health")
    html = machine.succeed("curl -fs http://127.0.0.1/")
    assert "tokenrouter" in html.lower(), html
    machine.succeed("test -s /var/lib/tokenrouter/.installed")
    machine.succeed("test -s /var/lib/tokenrouter/.secret-encryption-key")

    # Restart to verify declarative CONFIG_FILE startup after initial setup.
    machine.succeed("systemctl restart tokenrouter.service")
    machine.wait_for_unit("tokenrouter.service")
    machine.wait_for_open_port(8080)
    machine.succeed("curl -fs http://127.0.0.1/health")
    machine.succeed(
        "curl -fs -X POST http://127.0.0.1/api/v1/auth/login "
        "-H 'Content-Type: application/json' "
        "-d '{\"email\":\"admin@example.test\",\"password\":\"test-admin-password-123\"}'"
    )
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
