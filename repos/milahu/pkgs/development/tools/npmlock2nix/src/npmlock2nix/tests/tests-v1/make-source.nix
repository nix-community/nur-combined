{ testLib, npmlock2nix }:
let
  i = npmlock2nix.v1.internal;
  f = {
    sourceHashFunc = builtins.throw "Shouldn't be called";
    nodejs = null;
  };
in
testLib.runTests {
  testMakeSourceRegular = {
    expr = i.makeSource f "regular" {
      resolved = "https://example.com/package.tgz";
      integrity = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
    };
    expected = {
      integrity = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
      resolved = "file:///nix/store/rm32fd9z9snwr3i1v0gv6f5fh4abzqf3-package.tgz";
    };
  };

  testMakeSourceUrlFromVersion =
    let
      version = "https://gitlab.matrix.org/api/v4/projects/27/packages/npm/@matrix-org/olm/-/@matrix-org/olm-3.2.4.tgz";
    in
    {
      expr = i.makeSource f "url-from-version" {
        integrity = "sha512-ddaXWILlm1U0Z9qpcZffJjBFZRpz/GxQ1n/Qth3xKvYRUbniuPOgftNTDaxkEC4h04uJG5Ls/OdI1YJUyfuRzQ==";
        inherit version;
      };
      expected = {
        integrity = "sha512-ddaXWILlm1U0Z9qpcZffJjBFZRpz/GxQ1n/Qth3xKvYRUbniuPOgftNTDaxkEC4h04uJG5Ls/OdI1YJUyfuRzQ==";
        resolved = "file:///nix/store/qn1b7cpsw383kprpzvq4r1x3yis9bczn-olm-3.2.4.tgz";
        inherit version;
      };
    };
}
