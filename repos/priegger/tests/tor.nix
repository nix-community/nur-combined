let
  controlPort = 9051;
in
import ./make-test.nix (
  { ... }: {
    name = "tor";
    nodes = {
      default = {
        priegger.services.tor.enable = true;
      };
    };

    testScript =
      ''
        start_all()

        with subtest("should have tor running"):
            default.wait_for_unit("tor.service")
            default.wait_for_open_port(${toString controlPort})
            default.succeed("cat /etc/ssh/ssh_config | grep 'Host \*.onion'")
      '';
  }
)
