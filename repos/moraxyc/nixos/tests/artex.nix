{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "artex";

  nodes.machine = _: {
    imports = [ ../modules/services/web-apps/artex.nix ];

    services.artex = {
      enable = true;
      package = pkgs.artex;
    };
  };

  testScript = ''
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("artex.service")
    machine.wait_for_open_port(8787)
    machine.succeed("curl --fail http://127.0.0.1:8787/")
    machine.succeed("curl --fail http://127.0.0.1:8787/api/health")
    machine.succeed("test -s /var/lib/artex/keys/jwt.key")
    machine.wait_for_open_port(8788)
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
