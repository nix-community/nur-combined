{ pkgs, newScope }:
let
  callPackage = newScope (pkgs // self);

  self = {
    bitmap = callPackage ./bitmap.nix {};
  };
in self
