{ pkgs ? import <nixpkgs> {} }:
let
  fetchPixiv = pkgs.callPackage ./default.nix {};
  lib = pkgs.lib;

  # Helper: returns true if expression fails (assertion error or evaluation error)
  testAssertFails = expr:
    let result = builtins.tryEval expr;
    in !result.success;

  # Helper: returns true if expression succeeds
  testAssertSucceeds = expr:
    let result = builtins.tryEval expr;
    in result.success;

  fakeSha256 = lib.fakeSha256;

  # --- Input Validation Tests (must trigger assertion failures) ---

  # Invalid id: negative integer
  testInvalidIdNegativeInt = testAssertFails (fetchPixiv {
    id = -1;
    p = 0;
    sha256 = fakeSha256;
  });

  # Invalid id: zero
  testInvalidIdZeroInt = testAssertFails (fetchPixiv {
    id = 0;
    p = 0;
    sha256 = fakeSha256;
  });

  # Invalid id: non-numeric string
  testInvalidIdNonNumericString = testAssertFails (fetchPixiv {
    id = "abc";
    p = 0;
    sha256 = fakeSha256;
  });

  # Invalid id: string starting with zero
  testInvalidIdStringLeadingZero = testAssertFails (fetchPixiv {
    id = "0123";
    p = 0;
    sha256 = fakeSha256;
  });

  # Invalid id: empty string
  testInvalidIdEmptyString = testAssertFails (fetchPixiv {
    id = "";
    p = 0;
    sha256 = fakeSha256;
  });

  # Invalid p: negative integer
  testInvalidPNegative = testAssertFails (fetchPixiv {
    id = 81554929;
    p = -1;
    sha256 = fakeSha256;
  });

  # Invalid mirrors: empty list
  testInvalidMirrorsEmptyList = testAssertFails (fetchPixiv {
    id = 81554929;
    p = 0;
    sha256 = fakeSha256;
    mirrors = [];
  });

  # Invalid mirrors: list with empty string
  testInvalidMirrorsEmptyString = testAssertFails (fetchPixiv {
    id = 81554929;
    p = 0;
    sha256 = fakeSha256;
    mirrors = [ "pixiv.re" "" ];
  });

  # --- Parameter Default Tests ---

  # p defaults to 0 when not provided
  testDefaultP = testAssertSucceeds (fetchPixiv {
    id = 81554929;
    sha256 = fakeSha256;
  });

  # mirrors defaults when not provided
  testDefaultMirrors = testAssertSucceeds (fetchPixiv {
    id = 81554929;
    p = 0;
    sha256 = fakeSha256;
  });

  # --- Derivation Structure Tests (inspect without building) ---

  # Inspect the derivation attributes
  drv = fetchPixiv {
    id = 81554929;
    p = 0;
    sha256 = fakeSha256;
  };

  testOutputHashAlgo = drv.outputHashAlgo == "sha256";
  testOutputHashMode = drv.outputHashMode == "recursive";
  testNativeBuildInputs =
    let
      inputNames = map lib.getName drv.nativeBuildInputs;
    in
    builtins.all (name: builtins.elem name inputNames) [ "curl" "nss-cacert" "jq" ];
  testDerivationNameFormat = lib.hasPrefix "pixiv-" drv.name;

  # --- Mirror API Probe Tests ---
  testParallelApiProbe = lib.hasInfix "api.$mirror/v1/generate" drv.buildCommand;
  testMirrorSelection = lib.hasInfix "best_mirror" drv.buildCommand;
  testFastestMirror = lib.hasInfix "best_time" drv.buildCommand;

  # --- Filename Sanitization Tests ---
  testSanitizeSpecialChars = lib.hasInfix "[\\/\\\\:*?\"<>|]" drv.buildCommand;
  testSanitizeMergeSpaces = lib.hasInfix "s/  */ /g" drv.buildCommand;
  testSanitizeTrim = lib.hasInfix "s/^ //;s/ $//" drv.buildCommand;
  testSanitizeEmptyFallback = lib.hasInfix "unknown" drv.buildCommand;
  testSanitizeTruncate = lib.hasInfix "head -c" drv.buildCommand;

  # --- meta.json Schema Tests ---
  testMetaJsonId = lib.hasInfix "id: $id" drv.buildCommand;
  testMetaJsonP = lib.hasInfix "p: $p" drv.buildCommand;
  testMetaJsonTitle = lib.hasInfix "title: $title" drv.buildCommand;
  testMetaJsonArtist = lib.hasInfix "artist: {id: $artist_id, name: $artist_name}" drv.buildCommand;
  testMetaJsonMultiple = lib.hasInfix "multiple: ($multiple" drv.buildCommand;
  testMetaJsonUrl = lib.hasInfix "url: $url" drv.buildCommand;
  testMetaJsonExt = lib.hasInfix "ext: $ext" drv.buildCommand;
  testMetaJsonFilename = lib.hasInfix "filename: $filename" drv.buildCommand;

  # --- Valid Input Tests ---

  # Positive integer id + p=0 + valid sha256
  testValidIntId = testAssertSucceeds (fetchPixiv {
    id = 81554929;
    p = 0;
    sha256 = fakeSha256;
  });

  # String id matching ^[1-9][0-9]*$
  testValidStringId = testAssertSucceeds (fetchPixiv {
    id = "81554929";
    p = 0;
    sha256 = fakeSha256;
  });

  # Valid p=1 (non-zero page)
  testValidPNonzero = testAssertSucceeds (fetchPixiv {
    id = 81554929;
    p = 1;
    sha256 = fakeSha256;
  });

in
{
  # Input Validation Tests
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
    testNativeBuildInputs
    testDerivationNameFormat
    testValidIntId
    testValidStringId
    testValidPNonzero;

  # Mirror API Probe Tests
  inherit
    testParallelApiProbe
    testMirrorSelection
    testFastestMirror;

  # Filename Sanitization Tests
  inherit
    testSanitizeSpecialChars
    testSanitizeMergeSpaces
    testSanitizeTrim
    testSanitizeEmptyFallback
    testSanitizeTruncate;

  # meta.json Schema Tests
  inherit
    testMetaJsonId
    testMetaJsonP
    testMetaJsonTitle
    testMetaJsonArtist
    testMetaJsonMultiple
    testMetaJsonUrl
    testMetaJsonExt
    testMetaJsonFilename;
}