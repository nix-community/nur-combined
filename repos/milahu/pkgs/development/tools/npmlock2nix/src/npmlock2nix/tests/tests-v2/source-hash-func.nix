{ lib, npmlock2nix, testLib }:
let
  i = npmlock2nix.v2.internal;

  testGitHubMap = {
    foo-org.foo-repo."db1442a0556c2b133627ffebf455a78a1ced64b9" = "github-repo-hash";
  };
  testSpec = {
    type = "github";
    value = {
      org = "foo-org";
      repo = "foo-repo";
      rev = "db1442a0556c2b133627ffebf455a78a1ced64b9";
    };
  };
in
(testLib.runTests {
  testSimpleCase = {
    expr = i.sourceHashFunc testGitHubMap testSpec;
    expected = "github-repo-hash";
  };
})
