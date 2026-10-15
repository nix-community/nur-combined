{
  lib,
  config,
  _class,
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

  singleAssertionType = types.submodule {
    options = {
      assertion = mkOption {
        type = types.bool;
        description = "If true, then this assertion fails";
      };
      message = mkOption {
        type = types.str;
        description = "The message to display if this assertion fails";
      };
      fatal = mkOption {
        type = types.bool;
        default = true;
        description = "If false, then this effectively becomes a warning";
      };
    };
  };
in
{
  imports = lib.optional (_class == "nixos" || _class == "nixOnDroid") adapter;
  options.vacu = {
    assertions = mkOption {
      default = [ ];
      type = types.listOf singleAssertionType;
    };
    withAsserts = mkOption {
      readOnly = true;
      default = withAsserts;
      defaultText = "withAsserts function";
    };
  };
}
