{ lib, pkgs }:
rec {
  plist = { binary ? false }: {

    generate = name: value: pkgs.callPackage
      ({ runCommand, libplist }: runCommand name
        {
          nativeBuildInputs = [ libplist ];
          value = (builtins.toJSON value) + "       "; # plistutil requires the input string to be a minimum of 7 characters. See https://github.com/libimobiledevice/libplist/issues/238
          passAsFile = [ "value" ];
        } ''
        plistutil -f ${if binary then "bin" else "xml"} -i "$valuePath" -o "$out"
      '')
      { };

    type = with lib.types; let
      plistAtom = nullOr (oneOf [
        bool
        int
        float
        str
        path
      ]);
      valueType =
        (oneOf [
          (attrsOf (oneOf [ plistAtom valueType ]))
          (listOf (oneOf [ plistAtom valueType ]))
        ]) // {
          description = "Property list value";
        };
    in
    valueType;

  };
}
