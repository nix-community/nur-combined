# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
	p_310 = pkgs.python310Packages;
	p_311 = pkgs.python311Packages;


in
{
	# The `lib`, `modules`, and `overlay` names are special
	lib = import ./lib { inherit pkgs; }; # functions
	modules = import ./modules; # NixOS modules
	overlays = import ./overlays; # nixpkgs overlays

	# example-package = pkgs.callPackage ./pkgs/example-package { };
	# some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
	# ...
	alvr = pkgs.callPackage pkgs/alvr {};
	g13d = pkgs.callPackage pkgs/g13d {};
	gitignore-template = p_311.callPackage pkgs/gitignore-template {};
	python-jwt_310 = p_310.callPackage pkgs/python-jwt {python-ver = 310;};
	python-jwt_311 = p_311.callPackage pkgs/python-jwt {python-ver = 311;};
	timew-sync-client = p_311.callPackage pkgs/timew-sync-client {};
	vpuppr-gd3 = pkgs.callPackage pkgs/vpuppr-gd3 {};
	xgen = pkgs.callPackage pkgs/xgen {};


}
