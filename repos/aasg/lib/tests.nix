# To run the tests, do:
#
#     nix-instantiate --eval --strict --expr 'import ./tests.nix {}'
{ lib ? (import <nixpkgs> { }).lib }:

with import ./extension.nix { inherit lib; };
let
  evalFailure = { success = false; value = false; };

  runTestsOrDieTrying = tests:
    let
      results = runTests tests;
    in
    assert (traceValSeq results) == [ ]; true;
in
runTestsOrDieTrying {

  ############
  # attrsets #
  ############

  testCapitalizeAttrNames1 = {
    expr = capitalizeAttrNames { };
    expected = { };
  };

  testCapitalizeAttrNames2 = {
    expr = capitalizeAttrNames { ExecStart = "/bin/false"; };
    expected = { ExecStart = "/bin/false"; };
  };

  testCapitalizeAttrNames3 = {
    expr = capitalizeAttrNames { execStart = "/bin/false"; };
    expected = { ExecStart = "/bin/false"; };
  };

  testCapitalizeAttrNames4 = {
    expr = capitalizeAttrNames { serviceConfig.execStart = "/bin/false"; };
    expected = { ServiceConfig = { execStart = "/bin/false"; }; };
  };

  testConcatMapAttrs1 = {
    expr = concatMapAttrs' (n: v: singleton nameValuePair v n) { };
    expected = { };
  };

  testConcatMapAttrs2 = {
    expr = concatMapAttrs' (n: v: singleton (nameValuePair (toString v) n)) { x = 1; y = 2; };
    expected = { "1" = "x"; "2" = "y"; };
  };

  # TODO: what is the expected behavior here?
  #testConcatMapAttrs3 = {
  #  expr = concatMapAttrs' (n: v: singleton (nameValuePair (toString v) n)) { z = 1; y = 1; };
  #  expected = { "1" = "x"; };
  #};

  testUpdateNew1 = {
    expr = updateNew { } { };
    expected = { };
  };

  testUpdateNew2 = {
    expr = updateNew { a = 1; } { };
    expected = { a = 1; };
  };

  testUpdateNew3 = {
    expr = updateNew { } { a = 1; };
    expected = { a = 1; };
  };

  testUpdateNew4 = {
    expr = builtins.tryEval (updateNew { a = 1; } { a = 2; });
    expected = evalFailure;
  };

  testUpdateNew5 = {
    expr = updateNew { a = 1; } { b = 2; };
    expected = { a = 1; b = 2; };
  };

  testUpdateNew6 = {
    expr = builtins.tryEval (updateNew { a = 1; b = { c = 2; }; } { d = 4; b = { d = 4; }; });
    expected = evalFailure;
  };

  testUpdateNewRecursive1 = {
    expr = updateNewRecursive { } { };
    expected = { };
  };

  testUpdateNewRecursive2 = {
    expr = updateNewRecursive { a = 1; } { };
    expected = { a = 1; };
  };

  testUpdateNewRecursive3 = {
    expr = updateNewRecursive { } { a = 1; };
    expected = { a = 1; };
  };

  testUpdateNewRecursive4 = {
    expr = builtins.tryEval (updateNewRecursive { a = 1; } { a = 2; });
    expected = evalFailure;
  };

  testUpdateNewRecursive5 = {
    expr = updateNewRecursive { a = 1; } { b = 2; };
    expected = { a = 1; b = 2; };
  };

  testUpdateNewRecursive6 = {
    expr = updateNewRecursive { a = 1; b = { c = 2; }; } { d = 4; b = { d = 4; }; };
    expected = { a = 1; b = { c = 2; d = 4; }; d = 4; };
  };

  #########
  # lists #
  #########

  testIndexOfFound = {
    expr = indexOf "c" [ "a" "b" "c" "d" "e" ];
    expected = 2;
  };

  testIndexOfNotFound = {
    expr = indexOf "g" [ "a" "b" "c" "d" "e" ];
    expected = -1;
  };

  testIndexOfWrongType = {
    expr = indexOf 3 [ "a" "b" "c" "d" "e" ];
    expected = -1;
  };

  testIndexOfEmpty = {
    expr = indexOf (throw "shouldn't be evaluated") [ ];
    expected = -1;
  };

  testIsSubsetOf1 = {
    expr = isSubsetOf [ 1 2 3 4 5 ] [ 1 3 5 ];
    expected = true;
  };

  testIsSubsetOf2 = {
    expr = isSubsetOf [ 1 2 3 4 5 ] [ ];
    expected = true;
  };

  testIsSubsetOf3 = {
    expr = isSubsetOf [ ] [ 1 3 5 ];
    expected = false;
  };

  testIsSubsetOf4 = {
    expr = isSubsetOf [ ] [ ];
    expected = true;
  };

  ########
  # math #
  ########

  testAbs1 = {
    expr = abs 0;
    expected = 0;
  };

  testAbs2 = {
    expr = abs (-1);
    expected = 1;
  };

  testAbs3 = {
    expr = abs 1;
    expected = 1;
  };

  testAbs4 = {
    expr = abs 9223372036854775807;
    expected = 9223372036854775807;
  };

  testAbs5 = {
    expr = abs (-9223372036854775807);
    expected = 9223372036854775807;
  };

  testPow0 = {
    expr = pow 0 0;
    expected = 1;
  };

  testPow1 = {
    expr = pow 1 0;
    expected = 1;
  };

  testPow2 = {
    expr = pow 0 1;
    expected = 0;
  };

  testPow3 = {
    expr = pow 0 2;
    expected = 0;
  };

  testPow4 = {
    expr = pow 2 32;
    expected = 4294967296;
  };

  testPow5 = {
    expr = pow (-2) 32;
    expected = 4294967296;
  };

  testPow6 = {
    expr = pow (-9) 3;
    expected = -729;
  };

  testPow7 = {
    expr = pow (-3) 5;
    expected = -243;
  };

  testRem1 = {
    expr = rem 120 9;
    expected = 3;
  };

  testRem2 = {
    expr = rem (-120) 9;
    expected = -3;
  };

  testRem3 = {
    expr = rem 120 (-9);
    expected = 3;
  };

  testRem4 = {
    expr = rem 688258375 8765;
    expected = 688258375 - (688258375 / 8765) * 8765;
  };

  testRem5 = {
    expr = rem 688258375 (-620);
    expected = 688258375 - (688258375 / (-620)) * (-620);
  };

  ###########
  # strings #
  ###########

  testCapitalize1 = {
    expr = capitalize "";
    expected = "";
  };

  # tryEval doesn't catch this, wait for github:NixOS/nix#1230.
  #testCapitalize2 = {
  #  expr = builtins.tryEval (capitalize strings);
  #  expected = evalFailure;
  #};

  testCapitalize3 = {
    expr = capitalize "05:14";
    expected = "05:14";
  };

  testCapitalize4 = {
    expr = capitalize "90-default.conf";
    expected = "90-default.conf";
  };

  testCapitalize5 = {
    expr = capitalize "testCapitalize5";
    expected = "TestCapitalize5";
  };

  testParseHex1 = {
    expr = parseHex "";
    expected = 0;
  };

  testParseHex2 = {
    expr = builtins.tryEval (parseHex "-1");
    expected = evalFailure;
  };

  testParseHex3 = {
    expr = parseHex "0";
    expected = 0;
  };

  testParseHex4 = {
    expr = parseHex "f5";
    expected = 245;
  };

  testParseHex5 = {
    expr = parseHex "100000000";
    expected = 4294967296;
  };

  testParseHex6 = {
    expr = parseHex "7fffffffffffffff";
    expected = 9223372036854775807;
  };

  testParseHex7 = {
    expr = parseHex "10000000000000000";
    expected = null;
  };

}
