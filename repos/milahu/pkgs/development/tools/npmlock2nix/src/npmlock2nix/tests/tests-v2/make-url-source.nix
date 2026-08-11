{ npmlock2nix, testLib, lib }:
let
  inherit (testLib) noSourceOptions;
  name = "utils.logger";
  version = "1.0.0";
  resolved = "https://registry.npmjs.org/@apollo/utils.logger/-/utils.logger-1.0.0.tgz";
  integrity = "sha512-dx9XrjyisD2pOa+KsB5RcDbWIAdgC91gJfeyLCgy0ctJMjQe7yZK5kdWaWlaOoCeX0z6YI9iYlg7vMPyMpQF3Q==";
in
testLib.runTests {
  testUrlForDependency = {
    expr =
      let
        res = npmlock2nix.v2.internal.makeUrlSource noSourceOptions name version resolved integrity;
      in
      integrity == res.integrity && lib.hasPrefix "file:///nix/store" res.resolved;
    expected = true;
  };
}
