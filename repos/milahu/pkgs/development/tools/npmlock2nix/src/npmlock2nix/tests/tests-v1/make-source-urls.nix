{ npmlock2nix, testLib }:
testLib.runTests {
  testUrlForDependency = {
    expr = npmlock2nix.v1.internal.makeSourceAttrs "test" {
      resolved = "https://example.com/package.tgz";
      integrity = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
    };
    expected = {
      url = "https://example.com/package.tgz";
      hash = "sha1-hrGk3k+s4YCsVFqD8VA1I9j+0RU=";
    };
  };
}
