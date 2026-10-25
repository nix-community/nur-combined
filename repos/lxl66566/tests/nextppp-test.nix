let
  pkgs = import <nixpkgs> { };
  modules = import ../modules { };
in
pkgs.testers.runNixOSTest {
  name = "nextppp-service-test";

  nodes = {
    server = {
      imports = [ modules.nextppp ];
      services.nextppp = {
        enable = true;
        mode = "server";
        settings = {
          listen = "0.0.0.0:6666";
          password = "test-password";
        };
      };
      networking.firewall.allowedTCPPorts = [ 6666 ];
    };
    client = {
      imports = [ modules.nextppp ];
      services.nextppp = {
        enable = true;
        mode = "client";
        settings = {
          listen = "127.0.0.1:1080";
          password = "test-password";
          server.address = "server:6666";
          bond = {
            listen = "127.0.0.1:1081";
            links = 1;
          };
        };
      };
    };
  };

  testScript = ''
    server.wait_for_unit("nextppp.service")
    server.wait_for_open_port(6666)
    client.wait_for_unit("nextppp.service")
    client.wait_for_open_port(1080)
    client.wait_for_open_port(1081)
    # The bond inbound's link pool dials the server's regular address with
    # the bond-link session role; the single server port serves both roles.
    server.wait_until_succeeds(
      "journalctl -u nextppp --no-pager | grep -q 'bond link established'"
    )
    print(server.succeed("journalctl -u nextppp --no-pager"))
  '';
}
