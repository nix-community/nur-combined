{ pkgs ? import <nixpkgs> {} }:
let scope = pkgs.lib.makeScope pkgs.newScope (self: {
  # The `lib`, `modules`, and `overlay` names are special
  lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  otcl = self.callPackage ./pkgs/otcl { };
  tclcl = self.callPackage ./pkgs/tclcl { };
  ns-2 = self.callPackage ./pkgs/ns2 { };
  buildArb = self.callPackage ./pkgs/bioinf/arb/buildArb.nix { };
  arbcommon = self.callPackage ./pkgs/bioinf/arb/common { };
  arbcore = self.callPackage ./pkgs/bioinf/arb/core { };
  arbaisc = self.callPackage ./pkgs/bioinf/arb/aisc { };
  arbaisc_com = self.callPackage ./pkgs/bioinf/arb/aisc_com { };
  arbaisc_mkptps = self.callPackage ./pkgs/bioinf/arb/aisc_mkptps { };
  arbdb = self.callPackage ./pkgs/bioinf/arb/db { };
  arbslcb = self.callPackage ./pkgs/bioinf/arb/sl/cb { };
  arbprobe_com = self.callPackage ./pkgs/bioinf/arb/probe_com { };
  arbslhelix = self.callPackage ./pkgs/bioinf/arb/sl/helix { };
  sina = self.callPackage ./pkgs/bioinf/sina { };
}); 
in scope.packages scope
