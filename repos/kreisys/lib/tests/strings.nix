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

  "test isCamel helloWorld" = {
    expr = isCamel "helloWorld";
    expected = true;
  };

  "test isCamel HelloWorld" = {
    expr = isCamel "HelloWorld";
    expected = true;
  };

  "test camelToSnake helloWorld" = {
    expr     = camelToSnake "helloWorld";
    expected = "hello_world";
  };

  "test camelToSnake HelloWorld" = {
    expr     = camelToSnake "HelloWorld";
    expected = "hello_world";
  };
}
