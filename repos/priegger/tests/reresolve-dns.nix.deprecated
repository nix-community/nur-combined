import ./lib/make-test.nix (
  { ... }: {
    name = "reresolve-dns";
    nodes = {
      reresolveDns = {
        priegger.services.reresolve-dns.enable = true;
      };
    };

    testScript =
      ''
        # Check configuration
        with subtest("Timer exists"):
            reresolveDns.succeed("systemctl list-timers | grep reresolve-dns.timer")
      '';
  }
)
