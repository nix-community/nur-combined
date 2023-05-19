{ pkgs }:

with pkgs; {
  mkBoolOpt = default: description: lib.mkOption {
    inherit default;
    inherit description;
    type = lib.types.bool;
    example = true;
  };
  mkPrivateVar = default: lib.mkOption {
    inherit default;
    readOnly = true; 
    visible = false;

  };
}
