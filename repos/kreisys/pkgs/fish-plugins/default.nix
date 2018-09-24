{ lib, newScope, recurseIntoAttrs, fetchgit }:

let
  callPackage = newScope self;

  self = rec {
    packagePlugin = { name, src }: callPackage ./package-plugin.nix { inherit name src; };

    bobthefish = let
      inherit (lib.importJSON ./bobthefish.json) url rev sha256;
    in packagePlugin {
      name = "bobthefish-${rev}";
      src  = fetchgit { inherit url rev sha256; };
    };

    completions = recurseIntoAttrs (callPackage ./completions { });

    iterm2-integration = callPackage ./iterm2-integration.nix { };
  };
in self
