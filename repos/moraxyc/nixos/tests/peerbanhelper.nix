{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "peerbanhelper";

  nodes = {
    plain = _: {
      imports = [ ../modules/services/web-apps/peerbanhelper.nix ];

      services.peerbanhelper = {
        enable = true;
        package = pkgs.peerbanhelper;
      };
    };

    settingsOnly = _: {
      imports = [ ../modules/services/web-apps/peerbanhelper.nix ];

      services.peerbanhelper = {
        enable = true;
        package = pkgs.peerbanhelper;
        settings = {
          language = "zh_cn";
        };
      };
    };

    configured = _: {
      imports = [ ../modules/services/web-apps/peerbanhelper.nix ];

      services.peerbanhelper = {
        enable = true;
        package = pkgs.peerbanhelper;
        port = 9899;
        configureNginx = true;
        apiTokenFile = pkgs.writeText "pbh-api-token" "test-pbh-token";
        settings = {
          language = "zh_cn";
          privacy.analytics = false;
          ip-database.auto-update = false;
          btn.app-secret._secret = pkgs.writeText "pbh-btn-secret" "test-btn-secret";
        };
        profileSettings = {
          check-interval = 10000;
        };
      };
    };
  };

  testScript = ''
    from datetime import timedelta
    import json

    start_all()

    plain.wait_for_unit("peerbanhelper.service")
    plain.wait_for_open_port(9898)

    plain.wait_until_succeeds(
        "curl -fs http://127.0.0.1:9898/api/metadata/manifest | grep -q '\"success\"'",
        timeout=timedelta(seconds=90),
    )
    manifest = json.loads(plain.succeed("curl -fs http://127.0.0.1:9898/api/metadata/manifest"))
    assert manifest["success"] is True, manifest
    assert manifest["data"]["version"]["version"], manifest

    # Without an API token configured, protected endpoints ask for OOBE initialization (303 -> /init).
    assert (
        plain.succeed(
            "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:9898/api/general/status"
        )
        == "303"
    )
    webui = plain.succeed("curl -fs http://127.0.0.1:9898/")
    assert "peerbanhelper" in webui.lower(), webui

    plain.succeed("test -s /var/lib/peerbanhelper/config/config.yml")
    plain.succeed("test -s /var/lib/peerbanhelper/config/profile.yml")
    plain.succeed("test -s /var/lib/peerbanhelper/persist/peerbanhelper-nt.db")
    plain.succeed("test -s /var/log/peerbanhelper/latest.log")

    # Configured instance: token via LoadCredential, custom port, nginx, and merged YAML config.
    configured.wait_for_unit("peerbanhelper.service")
    configured.wait_for_unit("nginx.service")
    configured.wait_for_open_port(9899)
    configured.wait_for_open_port(80)

    assert (
        configured.succeed(
            "systemctl show -p Environment --value peerbanhelper.service"
        ).find("test-pbh-token")
        == -1
    )

    configured.wait_until_succeeds(
        "curl -fs http://127.0.0.1:9899/api/metadata/manifest | grep -q '\"success\"'",
        timeout=timedelta(seconds=90),
    )

    # Unauthenticated requests to protected endpoints are rejected (403).
    assert (
        configured.succeed(
            "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:9899/api/general/status"
        )
        == "403"
    )
    status = json.loads(
        configured.succeed(
            "curl -fs -H 'Authorization: Bearer test-pbh-token' http://127.0.0.1/api/general/status"
        )
    )
    assert status["success"] is True, status
    assert status["data"]["peerbanhelper"]["database_type"] == "SQLITE", status

    config_yml = configured.succeed("cat /var/lib/peerbanhelper/config/config.yml")
    assert "language: zh_cn" in config_yml, config_yml
    assert "test-btn-secret" in config_yml, config_yml
    assert "installation-id:" in config_yml, config_yml

    profile_yml = configured.succeed("cat /var/lib/peerbanhelper/config/profile.yml")
    assert "check-interval: 10000" in profile_yml, profile_yml

    # Mutable state survives restarts and remains merged with declarative settings.
    configured.succeed("systemctl restart peerbanhelper.service")
    configured.wait_for_unit("peerbanhelper.service")
    configured.wait_until_succeeds(
        "curl -fs -H 'Authorization: Bearer test-pbh-token' http://127.0.0.1/api/general/status | grep -q '\"success\"'",
        timeout=timedelta(seconds=90),
    )

    # Non-empty settings with empty profileSettings should not attempt to merge profile.yml.
    settingsOnly.wait_for_unit("peerbanhelper.service")
    settingsOnly.wait_for_open_port(9898)
    settings_only_config = settingsOnly.succeed("cat /var/lib/peerbanhelper/config/config.yml")
    assert "language: zh_cn" in settings_only_config, settings_only_config
    settingsOnly.succeed("test -s /var/lib/peerbanhelper/config/profile.yml")
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
