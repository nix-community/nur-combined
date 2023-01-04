{ self, pkgs, system }:
let
  package = self.lib.${system}.upstream-supported {
    inherit system;
    inherit (self.inputs.vulnix-pre-commit) packages;
  };
in package
