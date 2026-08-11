{ npmlock2nix, testLib }:
let
  i = npmlock2nix.v1.internal;
in
(testLib.runTests {
  testParsesARef =
    {
      expr = i.parseGitHubRef "github:foo/bar#939360f9d1bafa9019b6ff8739495c6c9101c4a1";
      expected = {
        parts = [ "github" [ ] "foo" [ ] "bar" [ ] "939360f9d1bafa9019b6ff8739495c6c9101c4a1" ];
        org = "foo";
        repo = "bar";
        rev = "939360f9d1bafa9019b6ff8739495c6c9101c4a1";
      };
    };

  # It would be nice if there was a way to test the failure
  # case but unfortunately we can't catch exceptions...
})
