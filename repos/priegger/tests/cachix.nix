import ./lib/make-test.nix (
  { ... }: {
    name = "cachix";
    nodes = {
      cachix = {
        priegger.services.cachix.enable = true;
      };
    };

    testScript =
      ''
        start_all()
        cachix.wait_for_unit("multi-user.target")
      '';
  }
)
