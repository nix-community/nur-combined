# todo: rename this module
# stuff that does actual configuring (so can't be in ./module.nix) but works in nixos module, home-manager modules, and nix-on-droid modules
{
  vacuModuleType,
  config,
  lib,
  vacuRoot,
  ...
}:
lib.optionalAttrs (vacuModuleType != "plain") {
  nix.registry = lib.mkIf (!config.vacu.isMinimal) {
    vacu.to = {
      type = "path";
      path = vacuRoot;
    };
  };
}
