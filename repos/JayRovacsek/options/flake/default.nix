{ config, lib, ... }:
with lib; {
  options.flake = mkOption {
    type = with types; anything;
    default = { };
    description = ''
      A value to enable flake recursion.
    '';
  };
}
