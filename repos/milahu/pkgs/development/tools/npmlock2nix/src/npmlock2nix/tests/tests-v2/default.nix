{ callPackage }:
{
  build = callPackage ./build.nix { };
  build-tests = callPackage ./build-tests.nix { };
  in-bundle-dep-test = callPackage ./examples-projects/in-bundle-dependency { };
  bundle-shebang-tests = callPackage ./examples-projects/bundled-dep-require-patch-shebang { };
  integration-tests = callPackage ./integration-tests { };
  patch-package = callPackage ./patch-package.nix { };
  make-url-source = callPackage ./make-url-source.nix { };
  node-modules = callPackage ./node-modules.nix { };
  parse-github-ref = callPackage ./parse-github-ref.nix { };
  patch-packagefile = callPackage ./patch-packagefile.nix { };
  read-lockfile = callPackage ./read-lockfile { };
  shell = callPackage ./shell.nix { };
  source-hash-func = callPackage ./source-hash-func.nix { };
}
