{ nurPath, lib, mkJob, mkTests, overlays, supportedSystems ? [ builtins.currentSystem ] }:

{ jobsetPrefix
, jobset

  # extra overlays to be used in the test environment
, customOverlays ? []

  # which sources of nixpkgs shall be used for `mkJob`
, sources ? lib.singleton { inherit supportedSystems; channel = "unstable"; }

  # additional tests to perform
, vmTests ? []
, libraryTests ? []
}:

let

  allOverlays = (builtins.attrValues overlays) ++ customOverlays ++ [
    (self: super:
      (import nurPath { pkgs = super; })
      // lib.optionalAttrs (vmTests != {}) {
        "${jobsetPrefix}-vm-tests" = vmTests;
      }
      // lib.optionalAttrs (libraryTests != []) {
        "${jobsetPrefix}-library-tests" = mkTests (map (path: self.callPackage path {}) libraryTests);
      })
  ];

  escapeChannel = builtins.replaceStrings [ "." ] [ "-" ];

in

lib.listToAttrs
  (lib.flip map sources
    (src: lib.nameValuePair ("${jobsetPrefix}-${escapeChannel src.channel}")
      (mkJob
        (src // { overlays = allOverlays; inherit jobset; }))))
