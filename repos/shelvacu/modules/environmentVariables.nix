{
  config,
  lib,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports =
    [ ]
    ++ (lib.optional (vacuModuleType == "nixos") {
      config.environment.variables = config.vacu.environment.variables;
    })
    ++ (lib.optional (vacuModuleType == "nix-on-droid") {
      config.environment.sessionVariables = config.vacu.environment.variables;
    });
  options.vacu.environment.variables = mkOption {
    type = types.attrsOf types.str;
    default = { };
  };
}
