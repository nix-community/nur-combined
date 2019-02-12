{ pkgs }:

with pkgs;
with lib;
with builtins;

rec {
  fixedWidthStringRight = lib.fixedWidthString;

  fixedWidthStringLeft = width: filler: str:
    let
      strw = lib.stringLength str;
      reqWidth = width - (lib.stringLength filler);
    in
      assert strw <= width;
      if strw == width then str else (fixedWidthStringLeft reqWidth filler str) + filler;

  capitalize = str: let
    # s't'r is supposed to represent [ "s" "t" "r" ]
    s't'r = stringToCharacters str;
    S't'r = [ (toUpper (head s't'r)) ] ++ tail s't'r;
    Str   = concatStrings S't'r;
  in Str;

  snakeToCamel = snake_str: assert isSnake snake_str; let
    snake'str = splitString "_" snake_str;
    camel'Str  = [ (head snake'str) ] ++ (map capitalize (tail snake'str));
    camelStr   = concatStrings camel'Str;
  in camelStr;

  # intersperseString "_" "foo" -> "f_o_o"
  intersperseString = sep: str: concatStrings (intersperse sep (stringToCharacters str));

  camelToSnake = camelStr: assert isCamel camelStr; let
    # Not sure this is the best way to do it but it works;
    # Also, this actually ends up being [ "came" [ "lS" ] "tr" ]
    came'lS'tr   = split "([[:lower:][:digit:]][[:upper:]])" camelStr;
    hybri'd_S'tr = map (e: if isString e then id e else (intersperseString "_" (head e))) came'lS'tr;
    hybrid_Str   = concatStrings hybri'd_S'tr;
    snake_str    = toLower hybrid_Str;
  in snake_str;

  # Easier than conversion; not that "foobar" would test positive for either but it doesn't really
  # matter since both conversions would still work and just return the same string.
  isSnake = str: match "[[:lower:]][[:lower:][:digit:]]+(_[[:lower:]][[:lower:][:digit:]]+)*" str != null;
  isCamel = str: match "[[:lower:]][[:lower:][:digit:]]+([[:upper:]]+[[:lower:][:digit:]]+)*" str != null;
}
