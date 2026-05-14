{ config, lib, ... }:

let
  inherit (builtins) elem;
  inherit (lib) getName mkOption;
  inherit (lib.types) listOf str;
in
{
  # Pending https://github.com/NixOS/nixpkgs/issues/55674
  options.allowedUnfree = mkOption { type = listOf str; default = [ ]; };
  config.nixpkgs.config.allowUnfreePredicate = p: elem (getName p) config.allowedUnfree;
}
