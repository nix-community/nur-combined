{ npmlock2nix, testLib }:
let
  i = npmlock2nix.v2.internal;
in
(testLib.runTests {
  testParsesASshGitRef =
    {
      expr = i.parseGitHubRef "git+ssh://git@github.com/tmcw/leftpad.git#db1442a0556c2b133627ffebf455a78a1ced64b9";
      expected = {
        parts = [ "git+ssh" [ ] "" [ ] "" [ ] "git@github.com" [ ] "tmcw" [ ] "leftpad.git" [ ] "db1442a0556c2b133627ffebf455a78a1ced64b9" ];
        org = "tmcw";
        repo = "leftpad";
        rev = "db1442a0556c2b133627ffebf455a78a1ced64b9";
      };
    };
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
  testParsesAGitRef =
    {
      expr = i.parseGitHubRef "leftpad@github:tmcw/leftpad#db1442a0556c2b133627ffebf455a78a1ced64b9";
      expected = {
        parts = [ "leftpad@github" [ ] "tmcw" [ ] "leftpad" [ ] "db1442a0556c2b133627ffebf455a78a1ced64b9" ];
        org = "tmcw";
        repo = "leftpad";
        rev = "db1442a0556c2b133627ffebf455a78a1ced64b9";
      };
    };

  testIsGitHubRefShort = {
    expr = i.isGitHubRef "github:znerol/libxmljs#0517e063347ea2532c9fdf38dc47878c628bf0ae";
    expected = true;
  };

  testIsGitHubRefFull = {
    expr = i.isGitHubRef "git+ssh://git@github.com/znerol/libxmljs.git#0517e063347ea2532c9fdf38dc47878c628bf0ae";
    expected = true;
  };

  testIsGitHubRefImplicitSsh = {
    expr = i.isGitHubRef "git@github.com/znerol/libxmljs.git#0517e063347ea2532c9fdf38dc47878c628bf0ae";
    expected = true;
  };

  testIsGitHubRefWithoutRef = {
    expr = i.isGitHubRefWithoutRev "github:frozeman/bignumber.js-nolookahead";
    expected = true;
  };

  testIsNotGitHubRefWithoutRef = {
    expr = i.isGitHubRefWithoutRev "github:znerol/libxmljs#0517e063347ea2532c9fdf38dc47878c628bf0ae";
    expected = false;
  };
})
