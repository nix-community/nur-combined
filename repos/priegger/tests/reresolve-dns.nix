import ./lib/make-test.nix (
  { ... }: {
    name = "reresolve-dns";
    nodes = {
      default = {
        priegger.services.reresolve-dns.enable = true;
      };
    };

    testScript =
      ''
        # Check configuration
        with subtest("Timer exists"):
            default.succeed("systemctl list-timers | grep reresolve-dns.timer")
      '';
  }
)
