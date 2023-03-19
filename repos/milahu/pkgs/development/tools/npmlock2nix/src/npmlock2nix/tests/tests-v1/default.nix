{ callPackage }:
{
  build = callPackage ./build.nix { };
  build-tests = callPackage ./build-tests.nix { };
  integration-tests = callPackage ./integration-tests { };
  make-github-source = callPackage ./make-github-source.nix { };
  make-source = callPackage ./make-source.nix { };
  make-source-urls = callPackage ./make-source-urls.nix { };
  node-modules = callPackage ./node-modules.nix { };
  parse-github-ref = callPackage ./parse-github-ref.nix { };
  patch-lockfile = callPackage ./patch-lockfile.nix { };
  patch-packagefile = callPackage ./patch-packagefile.nix { };
  read-lockfile = callPackage ./read-lockfile { };
  shell = callPackage ./shell.nix { };
  source-hash-func = callPackage ./source-hash-func.nix { };
}
