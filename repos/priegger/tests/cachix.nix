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
        cachix.wait_for_unit("multi-user.target")
      '';
  }
)
