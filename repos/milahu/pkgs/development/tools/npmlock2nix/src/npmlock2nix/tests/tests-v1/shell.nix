{ npmlock2nix, testLib, symlinkJoin, runCommand, nodejs, lib }:
testLib.runTests {
  # test that the shell expression uses the same (given) nodejs package for
  # both the shell and node_modules
  testUsesGivenNodeJSPackage =
    let
      custom_nodejs = symlinkJoin {
        name = "custom-nodejs";
        paths = [ nodejs ];
        version = "12.8.3";
        src = "/foo";
      };
      drv = npmlock2nix.v1.shell {
        src = ./examples-projects/single-dependency;
        nodejs = custom_nodejs;
      };
    in
    {
      expr = {
        inherit (drv) buildInputs;
        node_modules_nodejs = drv.node_modules.nodejs;
      };
      expected = {
        buildInputs = [ custom_nodejs drv.node_modules ];
        node_modules_nodejs = custom_nodejs;
      };
    };

  # test that we are passing the pre- & postBuild attributes to node_modules
  testPassPreBuildAttributeToNodeModules =
    let
      drv = npmlock2nix.v1.shell {
        src = ./examples-projects/single-dependency;
        node_modules_attrs.preBuild = "foobar in preBuild";
      };
    in
    {
      expr = drv.node_modules.preBuild;
      expected = "foobar in preBuild";
    };

  testPassPostBuildAttributeToNodeModules =
    let
      drv = npmlock2nix.v1.shell {
        src = ./examples-projects/single-dependency;
        node_modules_attrs.postBuild = "foobar in postBuild";
      };
    in
    {
      expr = drv.node_modules.postBuild;
      expected = "foobar in postBuild";
    };

  testPassthruIsHonored =
    let
      drv = npmlock2nix.v1.shell {
        src = ./examples-projects/single-dependency;
        passthru.test-attribute = 123;
      };
    in
    {
      expr = {
        inherit (drv.passthru) test-attribute;
        has_node_modules = drv.passthru ? node_modules;
      };
      expected = {
        test-attribute = 123;
        has_node_modules = true;
      };
    };

  testShellHookIsHonored =
    let
      drv = npmlock2nix.v1.shell {
        src = ./examples-projects/single-dependency;
        shellHook = "magic-string";
      };
    in
    {
      # the shellHook should now contain a bunch of lines (for setting up the node_modules symlink / copy) and the given line. Our line must be on a line of its own.
      expr =
        let
          lines = lib.splitString "\n" drv.shellHook;
          more_than_one_line = (builtins.length lines) > 1;
          last_line = builtins.head (lib.reverseList lines);
        in
        {
          inherit more_than_one_line last_line;
        };
      expected = {
        more_than_one_line = true;
        last_line = "magic-string";
      };
    };

}
