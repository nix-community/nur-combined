{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  otcl = pkgs.callPackage ./pkgs/otcl { };
  tclcl = pkgs.callPackage ./pkgs/tclcl { inherit otcl; };
  ns-2 = pkgs.callPackage ./pkgs/ns2 { inherit otcl tclcl; };
  buildArb = pkgs.callPackage ./pkgs/bioinf/arb/buildArb.nix { };
  arbcommon = pkgs.callPackage ./pkgs/bioinf/arb/common {
    inherit buildArb;
    };
  arbcore = pkgs.callPackage ./pkgs/bioinf/arb/core { 
    inherit buildArb arbcommon; 
    };
  arbaisc = pkgs.callPackage ./pkgs/bioinf/arb/aisc { 
    inherit buildArb arbcommon arbcore; 
   };
  arbaisc_com = pkgs.callPackage ./pkgs/bioinf/arb/aisc_com { 
    inherit buildArb arbcommon; 
   };
  arbaisc_mkptps = pkgs.callPackage ./pkgs/bioinf/arb/aisc_mkptps { 
    inherit buildArb arbcommon arbcore; 
   };
  arbdb = pkgs.callPackage ./pkgs/bioinf/arb/db { 
    inherit buildArb arbcore arbcommon arbslcb; 
    };
  arbslcb = pkgs.callPackage ./pkgs/bioinf/arb/sl/cb {
    inherit buildArb arbcore arbcommon; 
    };
  arbprobe_com = pkgs.callPackage ./pkgs/bioinf/arb/probe_com {
    inherit buildArb arbcore arbcommon arbaisc arbaisc_mkptps arbaisc_com; 
    };
  arbslhelix = pkgs.callPackage ./pkgs/bioinf/arb/sl/helix {
    inherit buildArb arbcore arbcommon arbdb; 
    };
  sina = pkgs.callPackage ./pkgs/bioinf/sina { 
    inherit arbdb arbcommon arbcore arbslhelix arbprobe_com arbaisc_com;
    };
}

