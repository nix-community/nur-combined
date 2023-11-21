{ lib, pkgs }:
rec {
  plist = {}: {

    generate = name: value: pkgs.callPackage
      ({ runCommand, libplist }: runCommand name
        {
          nativeBuildInputs = [ libplist ];
          value = builtins.toJSON value;
          passAsFile = [ "value" ];
        } ''
        plistutil -f xml -i "$valuePath" -o "$out"
      '')
      { };

    type = with lib.types; let
      primitiveType = nullOr oneOf [
        bool
        int
        float
        str
        path
      ];
      valueType = (oneOf [
        (attrsOf primitiveType)
        (listOf primitiveType)
      ]) // {
        description = "Property list value";
      };
    in
    valueType;

  };
}
