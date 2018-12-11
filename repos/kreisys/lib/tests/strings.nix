{ pkgs }:

with (import ../. { inherit pkgs; }).strings;

let
  str   = "Hello World";
  strln = pkgs.lib.stringLength str;

in {
  testFixedWidthStringLeft = {
    expr     = fixedWidthStringLeft (strln + 2) "X" str;
    expected = "${str}XX";
  };
}
