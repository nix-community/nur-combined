{
  config,
  lib,
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (vaculib) mkOutOption;
  inherit (config.vacu) systemKind;
in
{
  options = {
    vacu.systemKind = mkOption {
      type = types.enum [
        "minimal"
        "desktop" # need a better name for this; should include laptops; everything I intend to get computery-stuff done on.
        "laptop"
        "container"
        "server"
      ];
    };
    vacu.isContainer = mkOutOption (systemKind == "container");
    vacu.isMinimal = mkOption {
      type = types.bool;
      default = systemKind == "minimal" || systemKind == "container";
    };
    vacu.isGui = mkOption {
      type = types.bool;
      default = systemKind == "desktop" || systemKind == "laptop";
    };
    vacu.isDev = mkOption {
      type = types.bool;
      default = systemKind == "desktop" || systemKind == "laptop" || systemKind == "server";
    };
  };
}
