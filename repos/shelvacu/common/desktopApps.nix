{ lib, vacuModuleType, ... }:
lib.optionalAttrs (vacuModuleType == "nixos") {
  options.vacu.desktopApps = lib.mkEnableOption "asdf";
  #todo
}
