{lib}: let
  inherit
    (lib)
    mkOption
    types
    ;
in
  types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        default = "";
      };
    };
  }
