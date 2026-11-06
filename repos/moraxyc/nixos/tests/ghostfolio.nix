{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "ghostfolio";

  nodes.machine = _: {
    imports = [
      ../modules/services/web-apps/ghostfolio.nix
    ];

    services.ghostfolio = {
      enable = true;
      rootUrl = "http://localhost:3333";
      settings = {
        ACCESS_TOKEN_SALT = "test-access-token-salt";
        JWT_SECRET_KEY = "test-jwt-secret-key";
      };
    };
  };

  testScript = ''
    # Connecting to the socket starts the service, so do not probe the port first.
    machine.wait_for_unit("ghostfolio.socket")
    machine.fail("systemctl is-active --quiet ghostfolio.service")
    machine.succeed("curl -fs http://localhost:3333/api/v1/info")
    machine.wait_for_unit("ghostfolio.service")
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-ghostfolio.service")
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
