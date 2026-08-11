{ npmlock2nix, testLib }:
testLib.runTests {
  testPassthruIsHonored =
    let
      drv = npmlock2nix.v2.build {
        src = ./examples-projects/single-dependency;
        installPhase = "
          # should never run as we only test eval here
          exit 123
        ";
        passthru.test-attr = 123;
      };
    in
    {
      expr = {
        inherit (drv.passthru) test-attr;
        has_node_modules = drv.passthru ? node_modules;
      };
      expected = {
        test-attr = 123;
        has_node_modules = true;
      };
    };
}
