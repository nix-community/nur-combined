{ lib, newScope, recurseIntoAttrs, fetchgit }:

let
  callPackage = newScope self;

  self = rec {
    packagePlugin = callPackage ./package-plugin.nix { };

    bobthefish = let
      inherit (lib.importJSON ./bobthefish.json) url rev sha256;
    in packagePlugin {
      name = "bobthefish-${rev}";
      src  = fetchgit { inherit url rev sha256; };
    };

    completions = lib.callPackagesWith self ./completions { };

    iterm2-integration = callPackage ./iterm2-integration.nix { };
  };
in self
