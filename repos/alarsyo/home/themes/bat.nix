{ lib }:
with lib;
types.submodule {
  options = {
    name = mkOption {
      type = types.str;
      default = "";
    };
  };
}
