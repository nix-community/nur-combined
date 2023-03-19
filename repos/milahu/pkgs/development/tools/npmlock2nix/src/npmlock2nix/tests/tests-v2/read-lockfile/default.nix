{ npmlock2nix, testLib }:
let
  i = npmlock2nix.v2.internal;
in
(testLib.runTests {
  testParsesSimpleLockfile =
    {
      expr = i.readPackageLikeFile ./simple.json;
      expected = {
        name = "simple";
        version = "1.0.0";
        lockfileVersion = 1;
        requires = true;
        dependencies = {
          leftpad = {
            version = "0.0.1";
            resolved = "https://registry.npmjs.org/leftpad/-/leftpad-0.0.1.tgz";
            integrity = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
          };
        };
      };
    };

  # parse a lockfile that doesn't have dependencies so we can test that we
  # always have at least an empty attribute set of dependencies.
  testParsesLockfileWithoutDependencies =
    {
      expr = i.readPackageLikeFile ../examples-projects/no-dependencies/package-lock.json;
      expected = {
        name = "no-dependencies";
        version = "1.0.0";
        requires = true;
        lockfileVersion = 2;
        dependencies = { };
        packages = {
          "" = {
            license = "ISC";
            name = "no-dependencies";
            version = "1.0.0";
          };
        };
      };
    };
})
