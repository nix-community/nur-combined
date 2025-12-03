{
  inputs,
  pkgs,
  lib,
  config,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.vacu.sourceTree = mkOption {
    readOnly = true;
    type = types.package;
  };
  config = {
    vacu.sourceTree = pkgs.linkFarm "simple-inputs-tree" inputs;
  }
  // (lib.optionalAttrs (vacuModuleType == "nixos" || vacuModuleType == "nix-on-droid") {
    environment.etc = lib.optionalAttrs (!config.vacu.isMinimal) {
      "vacu/sources".source = "${config.vacu.sourceTree}";
    };
  });
}
