{ npmlock2nix, testLib }:
let
  i = npmlock2nix.v1.internal;
in
(testLib.runTests {
  testParsesSimpleLockfile =
    {
      expr = i.readLockfile ./simple.json;
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
      expr = i.readLockfile ../examples-projects/no-dependencies/package-lock.json;
      expected = {
        name = "no-dependencies";
        version = "1.0.0";
        lockfileVersion = 1;
        dependencies = { };
      };
    };
})
