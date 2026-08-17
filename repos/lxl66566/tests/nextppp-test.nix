let
  pkgs = import <nixpkgs> { };
  modules = import ../modules { };
in
pkgs.testers.runNixOSTest {
  name = "nextppp-service-test";

  nodes.machine =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ modules.nextppp ];

      services.nextppp = {
        enable = true;
        mode = "server";
        settings = {
          listen = "0.0.0.0:6666";
          password = "test-password";
        };
      };
    };

  testScript = ''
    machine.wait_for_unit("nextppp.service")

    machine.succeed("pgrep -f 'nextppp server'")

    print(machine.succeed("journalctl -u nextppp --no-pager"))
  '';
}
