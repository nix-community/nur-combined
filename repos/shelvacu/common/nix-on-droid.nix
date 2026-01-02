{ lib, vacuModuleType, ... }:
let
  inherit (lib) mkDefault;
in
lib.optionalAttrs (vacuModuleType == "nix-on-droid") {

  vacu.hostName = mkDefault "nix-on-droid";
  vacu.shortHostName = mkDefault "nod";
}
