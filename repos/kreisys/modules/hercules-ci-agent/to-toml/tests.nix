{ lib, src }:
let

  inherit (import src { inherit lib; }) toTOML;

  testCase =
    name: { input, expected }:
      let
        actual = toTOML input;
      in
        if builtins.fromTOML expected != input
        then builtins.abort "Error in test suite or fromTOML in case ${name}: ${builtins.toJSON (builtins.fromTOML expected)}"
        else
          if actual == expected
          then null
          else { inherit input expected actual; };

  run = tcs: { failures = lib.filterAttrs (k: v: v != null) (lib.mapAttrs testCase tcs); };

in
run {
  empty.input = {};
  empty.expected = "";

  keyStringValue.input = { hello = "world"; };
  keyStringValue.expected =
    ''hello = "world"
  '';

  keyBoolValue.input = { a = true; b = false; };
  keyBoolValue.expected = ''
    a = true
    b = false
  '';

  keyIntValue.input = { a = 0; b = 10000; c = -4; };
  keyIntValue.expected = ''
    a = 0
    b = 10000
    c = -4
  '';

  /*

  Maybe it's best to go with the inline syntax?

  tablesAndArrays.input = {
    fruit = [
      {
        name = "apple";
        physical = {
          color = "red";
          shape = "round";
        };
        variety = [
          { name = "red delicious"; }
          { name = "granny smith"; }
        ];
      }
      {
        name = "banana";
        variety = [
          { name = "plantain"; }
        ];
      }
    ];
  };
  tablesAndArrays.expected = ''
    [[fruit]]
    name = "apple"
      [fruit.physical]
        color = "red"
        shape = "round"
      [[fruit.variety]]
        name = "red delicious"
      [[fruit.variety]]
        name = "granny smith"
    [[fruit]]
      name = "banana"
      [[fruit.variety]]
        name = "plantain"
  '';

  */
}
