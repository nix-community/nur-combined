{ lib, self, ... }:

{
  name = "mistserver";

  nodes.server = {
    imports = [ self.nixosModules.mistserver ];
    services.mistserver = {
      enable = true;
      openFirewall = true;
    };
  };

  testScript = ''
    start_all()
    with subtest("start mistserver"):
        server.wait_for_unit("mistserver.service")
        server.wait_for_open_port(4242)
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
