{ lib, callPackage, ... }:
let
  version = builtins.fromJSON (builtins.readFile ../version.json);
  digitChars = builtins.genList (x: builtins.toString x) 10;
  removeBadSymbols = str: lib.replaceStrings
    [ " " "." ] [ "_" "-" ]
    str; # i know that it's morally wrong but there is no other way, nix doesn't support regex substitution
  prefixNumber = str:
    if builtins.elem (builtins.substring 0 1 str) digitChars
    then "_" + str else str;
  sanitizeIdentifier = str: prefixNumber (removeBadSymbols str);
  generateParamsFromFile = file: builtins.map
    (dir: { inherit dir; pname = sanitizeIdentifier dir; })
    (builtins.fromJSON (builtins.readFile file));
in
{
  themes = builtins.listToAttrs (
    builtins.map
      (theme: lib.nameValuePair theme.pname (
        callPackage ./default-theme.nix {
          pkgParams = {
            inherit (theme) dir pname;
            inherit version;
          };
        }
      ))
      (generateParamsFromFile ./themes.json)
  );
  fonts = builtins.listToAttrs (
    builtins.map
      (font: lib.nameValuePair font.pname (
        callPackage ./default-font.nix {
          pkgParams = {
            inherit (font) dir pname;
            inherit version;
          };
        }
      ))
      (generateParamsFromFile ./fonts.json)
  );
}
# that is so wrong...
