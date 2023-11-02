# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
	p_39 = pkgs.python39Packages;
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
	gitignore-template = pkgs.callPackage pkgs/gitignore-template {};
	llama-cpp-python_310 = p_310.callPackage pkgs/llama-cpp-python {python-ver = 310;};
	llama-cpp-python_311 = p_311.callPackage pkgs/llama-cpp-python {python-ver = 311;};
	python-jwt_39 = p_39.callPackage pkgs/python-jwt {python-ver = 39;};
	python-jwt_310 = p_310.callPackage pkgs/python-jwt {python-ver = 310;};
	python-jwt_311 = p_311.callPackage pkgs/python-jwt {python-ver = 311;};
	timew-sync-client_39 = p_39.callPackage pkgs/timew-sync-client {python-ver = 39;};
	timew-sync-client_310 = p_310.callPackage pkgs/timew-sync-client {python-ver = 310;};
	timew-sync-client_311 = p_311.callPackage pkgs/timew-sync-client {python-ver = 311;};
	vpuppr-gd3 = pkgs.callPackage pkgs/vpuppr-gd3 {};


}
