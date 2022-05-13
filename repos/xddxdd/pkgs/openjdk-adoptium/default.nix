{ lib
, callPackage
, ...
} @ args:

lib.mapAttrs
  (k: v: callPackage (import ./jdk-linux-base.nix { sources = v; }) { })
  (lib.importJSON ./sources.json)
