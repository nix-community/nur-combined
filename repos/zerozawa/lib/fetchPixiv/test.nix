{ pkgs ? import <nixpkgs> {} }:
let
  fetchPixiv = pkgs.callPackage ./default.nix {};
  lib = pkgs.lib;

  testAssertFails = expr:
    let result = builtins.tryEval expr;
    in !result.success;

  testAssertSucceeds = expr:
    let result = builtins.tryEval expr;
    in result.success;

  fakeSha256 = lib.fakeSha256;

  # --- Input Validation Tests ---
  testInvalidIdNegativeInt = testAssertFails (fetchPixiv {
    id = -1; p = 0; sha256 = fakeSha256;
  });
  testInvalidIdZeroInt = testAssertFails (fetchPixiv {
    id = 0; p = 0; sha256 = fakeSha256;
  });
  testInvalidIdNonNumericString = testAssertFails (fetchPixiv {
    id = "abc"; p = 0; sha256 = fakeSha256;
  });
  testInvalidIdStringLeadingZero = testAssertFails (fetchPixiv {
    id = "0123"; p = 0; sha256 = fakeSha256;
  });
  testInvalidIdEmptyString = testAssertFails (fetchPixiv {
    id = ""; p = 0; sha256 = fakeSha256;
  });
  testInvalidPNegative = testAssertFails (fetchPixiv {
    id = 81554929; p = -1; sha256 = fakeSha256;
  });
  testInvalidMirrorsEmptyList = testAssertFails (fetchPixiv {
    id = 81554929; p = 0; sha256 = fakeSha256; mirrors = [];
  });
  testInvalidMirrorsEmptyString = testAssertFails (fetchPixiv {
    id = 81554929; p = 0; sha256 = fakeSha256; mirrors = [ "pixiv.re" "" ];
  });

  # --- Parameter Default Tests ---
  testDefaultP = testAssertSucceeds (fetchPixiv {
    id = 81554929; sha256 = fakeSha256;
  });
  testDefaultMirrors = testAssertSucceeds (fetchPixiv {
    id = 81554929; p = 0; sha256 = fakeSha256;
  });

  # --- Derivation Structure Tests ---
  drv = fetchPixiv {
    id = 81554929; p = 0; sha256 = fakeSha256;
  };

  testOutputHashAlgo = drv.outputHashAlgo == "sha256";
  testOutputHashMode = (drv.outputHashMode or "flat") == "flat";
  testDerivationNameFormat = lib.hasPrefix "pixiv-81554929-p0." drv.name;
  testNameContainsExt = builtins.match "pixiv-[0-9]+-p[0-9]+\\.[a-zA-Z0-9]+" drv.name != null;

  # --- Valid Input Tests ---
  testValidIntId = testAssertSucceeds (fetchPixiv {
    id = 81554929; p = 0; sha256 = fakeSha256;
  });
  testValidStringId = testAssertSucceeds (fetchPixiv {
    id = "81554929"; p = 0; sha256 = fakeSha256;
  });
  testValidPNonzero = testAssertSucceeds (fetchPixiv {
    id = 81554929; p = 1; sha256 = fakeSha256;
  });

in
{
  inherit
    testInvalidIdNegativeInt
    testInvalidIdZeroInt
    testInvalidIdNonNumericString
    testInvalidIdStringLeadingZero
    testInvalidIdEmptyString
    testInvalidPNegative
    testInvalidMirrorsEmptyList
    testInvalidMirrorsEmptyString
    testDefaultP
    testDefaultMirrors
    testOutputHashAlgo
    testOutputHashMode
    testDerivationNameFormat
    testNameContainsExt
    testValidIntId
    testValidStringId
    testValidPNonzero;
}
