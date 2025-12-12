{ lib, ... }:
let
  inherit (lib) types;
in
{
  options.flake.qb = lib.mkOption {
    type = types.lazyAttrsOf types.package;
    default = { };
  };
}
