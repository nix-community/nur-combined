{ lib ? import <nixpkgs/lib>}:

let
  names = import ./names.nix    { inherit lib; };

  attrs = import ./attrsets.nix {
    inherit lib;
    inherit (names) camelToSnake snakeToCamel;
  };

  stringify'     = import ./stringify.nix {
    inherit lib;
    inherit (names) camelToSnake isCamel isSnake;
    inherit (attrs) transformAttrNames;
  };

  terraformStubs = import ./terraform-stubs.nix {
    inherit lib;
    inherit (stringify') stringify stringifyAttrs;
  };

in rec {
  inherit names attrs terraformStubs;

  inherit (names) capitalize snakeToCamel camelToSnake isSnake isCamel;
  inherit (attrs) attrsSnakeToCamel attrsCamelToSnake transformAttrNames;

  inherit (stringify') stringify stringifyAttrs;

}
