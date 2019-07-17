{ branch ? "master", fork ? "ghc", url ? null, ncursesVersion ? "6" }:
let
  np = import <nixpkgs> {};
  ghc = self: ref: self.callPackage ./artifact.nix {} ref;

  gitlabConfig = self: (self.callPackage ./gitlab-artifact.nix {} {
                    inherit fork branch;
                  });
  directConfig = { bindistTarball = builtins.fetchurl url;
                   inherit ncursesVersion; };

  config = self: if url == null then (gitlabConfig self) else directConfig;
  ol = self: super:
    {
      ghcHEAD =
        ghc self (config self) ;
      ghc-head-from = self.callPackage ./ghc-head-from.nix {};
    };
in
  import <nixpkgs> { overlays = [ol]; }
