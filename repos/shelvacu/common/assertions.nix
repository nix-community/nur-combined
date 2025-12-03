{
  lib,
  vacuModuleType,
  config,
  ...
}:
let
  inherit (lib) mkOption types filter;
  fatalAssertions = map (x: x.message) (filter (x: !x.assertion && x.fatal) config.vacu.assertions);
  triggeredWarnings = map (x: x.message) (
    filter (x: !x.assertion && !x.fatal) config.vacu.assertions
  );
  withAsserts =
    x:
    if fatalAssertions != [ ] then
      throw ''

        Failed assertions:
        ${lib.concatStringsSep "\n" (map (x: "- ${x}") fatalAssertions)}''
    else
      lib.showWarnings triggeredWarnings x;

  adapter = {
    config = {
      assertions = map (x: { inherit (x) assertion message; }) (
        filter (x: x.fatal) config.vacu.assertions
      );
      warnings = triggeredWarnings;
    };
  };
in
{
  imports = lib.optional (vacuModuleType != "plain") adapter;
  options.vacu.assertions = mkOption {
    default = [ ];
    type = types.listOf (
      types.submodule {
        options.assertion = mkOption { type = types.bool; };
        options.message = mkOption { type = types.str; };
        options.fatal = mkOption {
          type = types.bool;
          default = true;
        };
      }
    );
  };
  options.vacu.withAsserts = mkOption {
    readOnly = true;
    default = withAsserts;
  };
}
