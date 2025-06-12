{ lib, callPackage, ... }:
lib.mapAttrs (k: v: callPackage (import ./jdk-linux-base.nix { sources = v; }) { }) (
  lib.importJSON ./sources.json
)
