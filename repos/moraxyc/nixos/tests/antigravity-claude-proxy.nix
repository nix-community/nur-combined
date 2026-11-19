{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "antigravity-claude-proxy";

  nodes = {
    plain = _: {
      imports = [ ../modules/services/web-apps/antigravity-claude-proxy.nix ];

      services.antigravity-claude-proxy = {
        enable = true;
        package = pkgs.antigravity-claude-proxy;
        settings = {
          logLevel = "debug";
          maxAccounts = 3;
        };
      };
    };

    protected = _: {
      imports = [ ../modules/services/web-apps/antigravity-claude-proxy.nix ];

      services.antigravity-claude-proxy = {
        enable = true;
        package = pkgs.antigravity-claude-proxy;
        configureNginx = true;
        strategy = "sticky";
        apiKeyFile = pkgs.writeText "api-key" "test-api-key";
        webuiPasswordFile = pkgs.writeText "webui-password" "test-webui-password";
      };
    };
  };

  testScript = ''
    start_all()

    plain.wait_for_unit("antigravity-claude-proxy.service")
    plain.wait_for_open_port(8080)

    plain.succeed("test -d /var/lib/antigravity-claude-proxy")
    config = plain.succeed("cat /var/lib/antigravity-claude-proxy/.config/antigravity-proxy/config.json")
    assert '"maxAccounts": 3' in config, config
    assert '"logLevel": "debug"' in config, config

    # Unauthenticated access stays open when no secrets are configured.
    health = plain.succeed("curl -fs http://127.0.0.1:8080/health")
    assert '"status":"ok"' in health, health
    assert '"total":0' in health, health
    dashboard = plain.succeed("curl -fs http://127.0.0.1:8080/")
    assert "antigravity" in dashboard.lower(), dashboard

    # Configured secrets are exported from credentials.
    protected.wait_for_unit("antigravity-claude-proxy.service")
    protected.wait_for_unit("nginx.service")
    protected.wait_for_open_port(80)

    assert (
        protected.succeed(
            "systemctl show -p Environment --value antigravity-claude-proxy.service"
        ).find("test-api-key")
        == -1
    )
    protected.fail("curl -fs http://127.0.0.1:8080/health")
    protected.succeed(
        "curl -fs -H 'X-WebUI-Password: test-webui-password' http://127.0.0.1:8080/health"
    )
    protected.succeed(
        "curl -fs -H 'X-WebUI-Password: test-webui-password' http://127.0.0.1/health"
    )

    # The strategy flag is applied, and /v1 requires the API key.
    logs = protected.succeed("journalctl -u antigravity-claude-proxy.service")
    assert "Sticky" in logs, logs
    assert (
        protected.succeed(
            "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/v1/models"
        )
        == "401"
    )
    # Without accounts the model list is unavailable, but the key is accepted.
    assert (
        protected.succeed(
            "curl -s -o /dev/null -w '%{http_code}' -H 'X-Api-Key: test-api-key' http://127.0.0.1/v1/models"
        )
        == "503"
    )

    # Dashboard state written at runtime lives in the state directory and survives restarts.
    protected.succeed("mkdir -p /var/lib/antigravity-claude-proxy/.config/antigravity-proxy")
    protected.succeed(
        "printf '%s' '{\"accounts\": [], \"settings\": {}, \"activeIndex\": 0}' > "
        "/var/lib/antigravity-claude-proxy/.config/antigravity-proxy/accounts.json"
    )
    protected.succeed("systemctl restart antigravity-claude-proxy.service")
    protected.wait_for_unit("antigravity-claude-proxy.service")
    protected.succeed(
        "test -s /var/lib/antigravity-claude-proxy/.config/antigravity-proxy/accounts.json"
    )
    protected.wait_until_succeeds(
        "curl -fs -H 'X-WebUI-Password: test-webui-password' http://127.0.0.1/health",
        timeout=30,
    )
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
