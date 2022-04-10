{lib}: let
  inherit
    (lib)
    mkOption
    types
    ;

  mkColorOption = import ./color.nix {inherit lib;};
in
  types.submodule {
    options = {
      theme = mkOption {
        type = types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              default = "plain";
            };
            overrides = mkOption {
              type = types.attrsOf types.str;
              default = {};
            };
          };
        };
        default = {};
      };
    };
  }
