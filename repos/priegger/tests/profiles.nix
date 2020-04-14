import ./lib/make-test.nix (
  { ... }: {
    name = "profiles";
    nodes = {
      desktop = {
        imports = [
          ../modules/profiles/desktop.nix
        ];
      };
      headless = {
        imports = [
          ../modules/profiles/headless.nix
        ];
      };
    };

    testScript =
      ''
        def checkCommonProperties(machine):
            machine.require_unit_state("sshd")
            machine.wait_for_open_port("22")


        start_all()

        with subtest("desktop starts"):
            desktop.wait_for_unit("multi-user.target")
            checkCommonProperties(desktop)

            desktop.wait_for_unit("display-manager.service")

        with subtest("headless starts"):
            headless.wait_for_unit("multi-user.target")
            checkCommonProperties(headless)
      '';
  }
)
