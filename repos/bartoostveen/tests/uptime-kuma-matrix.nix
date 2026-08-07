{ lib, self, ... }:

let
  port = 12345;
in
{
  name = "uptime-kuma-matrix";

  nodes.server = {
    imports = [ self.nixosModules.uptime-kuma-matrix ];
    services.uptime-kuma-matrix = {
      enable = true;
      settings = { inherit port; };
    };
  };

  testScript = ''
    start_all()
    with subtest("start uptime-kuma-matrix"):
        server.wait_for_unit("uptime-kuma-matrix.service")
        server.wait_for_open_port(${toString port})
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
