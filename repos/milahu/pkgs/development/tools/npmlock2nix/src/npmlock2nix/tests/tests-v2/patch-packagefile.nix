{ lib, npmlock2nix, testLib }:
let
  i = npmlock2nix.v2.internal;
  noSourceOptions = {
    sourceHashFunc = _: null;
    nodejs = null;
  };
in
(testLib.runTests {
  testTurnsGitHubRefsToWildcards = {
    expr = (i.patchPackagefile noSourceOptions (i.readPackageLikeFile ./examples-projects/github-dependency/package.json)).dependencies.leftpad;
    expected = "*";
  };
  testHandlesBranches = {
    expr = (i.patchPackagefile noSourceOptions (i.readPackageLikeFile ./examples-projects/github-dependency-branch/package.json)).dependencies.leftpad;
    expected = "*";
  };
  testHandlesDevDependencies = {
    expr = (i.patchPackagefile noSourceOptions (i.readPackageLikeFile ./examples-projects/github-dev-dependency/package.json)).devDependencies.leftpad;
    expected = "*";
  };
})
