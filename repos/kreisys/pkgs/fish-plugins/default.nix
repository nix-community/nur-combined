{ pkgs, stdenv, lib, newScope, recurseIntoAttrs, fetchgit }:

stdenv.lib.makeScope newScope (self: with self; let
  callPackages = lib.callPackagesWith (pkgs // self);
in {
    packagePlugin = callPackage ./package-plugin.nix { };

    bobthefish = let
      inherit (lib.importJSON ./bobthefish.json) url rev sha256;
    in packagePlugin {
      name = "bobthefish-${rev}";
      src  = fetchgit { inherit url rev sha256; };
    };

    completions = recurseIntoAttrs (callPackages ./completions {});

    iterm2-integration = callPackage ./iterm2-integration.nix { };
})
