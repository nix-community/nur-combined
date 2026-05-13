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
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-ghostfolio.service")
    machine.wait_for_unit("ghostfolio.service")
    machine.wait_for_open_port(3333)
    machine.succeed("curl -fs http://localhost:3333/api/v1/info")
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
