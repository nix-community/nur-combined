let
  pkgs = import <nixpkgs> { };
  modules = import ../modules { };
in
pkgs.testers.runNixOSTest {
  name = "selector4nix-service-test";

  nodes.machine =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ modules.selector4nix ];

      services.selector4nix = {
        enable = true;
        settings = {
          server = {
            ip = "127.0.0.1";
            port = 5496;
          };
          substituters = [
            {
              url = "https://cache.nixos.org/";
            }
          ];
        };
      };
    };

  testScript = ''
    machine.wait_for_unit("selector4nix.service")

    machine.succeed("pgrep -f selector4nix")

    print(machine.succeed("journalctl -u selector4nix --no-pager"))
  '';
}
