{ pkgs ? import <nixpkgs> {} }:
let scope = pkgs.lib.makeScope pkgs.newScope (self: rec {
  perlPackages          = self.callPackage ./pkgs/perl-packages.nix	{
     inherit (pkgs) perlPackages; 
  } // pkgs.perlPackages // {
    recurseForDerivations = false;
  };
  inherit (perlPackages) AIMicroStructure;
  portfolio-performance = self.callPackage ./portfolio-performance	{};
  realvnc               = self.callPackage ./realvnc 			{};
} ); 
in scope.packages scope
