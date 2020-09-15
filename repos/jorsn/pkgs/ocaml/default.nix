{ lib, ocaml-ng }:

let
  extend = opkgs: opkgs.overrideScope' (self: super:
    lib.mapAttrs (n: p: self.callPackage p {}) {
      patoline = ./patoline;
    }
  );
in lib.mapAttrs (n: opkgs: extend opkgs) ocaml-ng
