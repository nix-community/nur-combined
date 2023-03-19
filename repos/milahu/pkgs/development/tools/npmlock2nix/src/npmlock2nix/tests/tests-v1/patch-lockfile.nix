{ npmlock2nix, testLib, lib }:
let
  inherit (testLib) noSourceOptions;
in
testLib.runTests {

  testPatchDependencyHandlesGitHubRefsInRequires = {
    expr =
      let
        libxmljsUrl = (npmlock2nix.v1.internal.patchDependency [ ] noSourceOptions "test" {
          version = "github:tmcw/leftpad#db1442a0556c2b133627ffebf455a78a1ced64b9";
          from = "github:tmcw/leftpad#db1442a0556c2b133627ffebf455a78a1ced64b9";
          integrity = "sha512-8/UvHFG90J4O4QNRzb0jB5Ni1QuvuB7XFTLfDMQnCzAsFemF29VKnNGUESFFcSP/r5WWh/PMe0YRz90+3IqsUA==";
          requires = {
            libxmljs = "github:znerol/libxmljs#0517e063347ea2532c9fdf38dc47878c628bf0ae";
          };
        }
        ).result.requires.libxmljs;
      in
      lib.hasPrefix builtins.storeDir libxmljsUrl;
    expected = true;
  };

  testBundledDependenciesAreRetained = {
    expr = (npmlock2nix.v1.internal.patchDependency [ ] noSourceOptions "test" {
      bundled = true;
      integrity = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
      something = "bar";
      dependencies = { };
    }).result;
    expected = {
      bundled = true;
      integrity = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
      something = "bar";
      dependencies = { };
    };
  };

  testPatchLockfileWithoutDependencies = {
    expr = (npmlock2nix.v1.internal.patchLockfile noSourceOptions ./examples-projects/no-dependencies/package-lock.json).result.dependencies;
    expected = { };
  };

  testPatchDependencyDoesntDropAttributes = {
    expr = (npmlock2nix.v1.internal.patchDependency [ ] noSourceOptions "test" {
      a = 1;
      foo = "something";
      resolved = "https://examples.com/something.tgz";
      integrity = "sha1-00000000000000000000000+0RU=";
      dependencies = { };
    }).result;
    expected = {
      a = 1;
      foo = "something";
      resolved = "file:///nix/store/k2rgngn9cmhz4g3kzxmvhx5r40qvnwcf-something.tgz";
      integrity = "sha1-00000000000000000000000+0RU=";
      dependencies = { };
    };
  };

  testPatchDependencyPatchesDependenciesRecursively = {
    expr = (npmlock2nix.v1.internal.patchDependency [ ] noSourceOptions "test" {
      a = 1;
      foo = "something";
      resolved = "https://examples.com/something.tgz";
      integrity = "sha1-00000000000000000000000+0RU=";
      dependencies.a = {
        resolved = "https://examples.com/somethingelse.tgz";
        integrity = "sha1-00000000000000000000000+00U=";
      };
    }).result;

    expected = {
      a = 1;
      foo = "something";
      resolved = "file:///nix/store/k2rgngn9cmhz4g3kzxmvhx5r40qvnwcf-something.tgz";
      integrity = "sha1-00000000000000000000000+0RU=";
      dependencies.a = {
        resolved = "file:///nix/store/1cf0n1xb5pad8ib3xyzbzzddfknfxvkc-somethingelse.tgz";
        integrity = "sha1-00000000000000000000000+00U=";
      };
    };
  };

  testPatchLockfileTurnsUrlsIntoStorePaths = {
    expr =
      let
        deps = (npmlock2nix.v1.internal.patchLockfile noSourceOptions ./examples-projects/single-dependency/package-lock.json).result.dependencies;
      in
      lib.count (dep: lib.hasPrefix "file:///nix/store/" dep.resolved) (lib.attrValues deps);
    expected = 1;
  };

  testPatchLockfileTurnsGitHubUrlsIntoStorePaths = {
    expr =
      let
        leftpad = (npmlock2nix.v1.internal.patchLockfile noSourceOptions ./examples-projects/github-dependency/package-lock.json).result.dependencies.leftpad;
      in
      lib.hasPrefix ("file://" + builtins.storeDir) leftpad.version;
    expected = true;
  };

  testConvertPatchedLockfileToJSON = {
    expr = builtins.typeOf (builtins.toJSON (npmlock2nix.v1.internal.patchLockfile noSourceOptions ./examples-projects/nested-dependencies/package-lock.json).result) == "string";
    expected = true;
  };

  testPatchedLockFile = {
    expr = testLib.hashFile (npmlock2nix.v1.internal.patchedLockfile noSourceOptions ./examples-projects/nested-dependencies/package-lock.json).result;
    expected = "980323c3a53d86ab6886f21882936cfe7c06ac633993f16431d79e3185084414";
  };

}
