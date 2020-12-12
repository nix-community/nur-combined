# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
	# The `lib`, `modules`, and `overlay` names are special
	lib = import ./lib { inherit pkgs; }; # functions
	modules = import ./modules; # NixOS modules
	overlays = import ./overlays; # nixpkgs overlays

	# Locally apply overlay on to pkgs
	pkgsGnomeExtensions = pkgs.lib.fix (self: pkgs // (overlays.gnome-extensions self pkgs));
in
rec {
	inherit lib modules overlays;

	buildShellExtension = pkgsGnomeExtensions.gnomeExtensions.buildShellExtension;
	buildShellExtension2 = pkgsGnomeExtensions.gnomeExtensions.buildShellExtension2;

	gnomeExtensions = pkgs.recurseIntoAttrs (let
		extensions-index = builtins.fromJSON (builtins.readFile ./lib/extensions.json);
		extensions = builtins.map buildShellExtension2 extensions-index;
	in
		(builtins.listToAttrs (builtins.map (e: {name = e.pname; value = e;}) extensions))
	);

	matrix-conduit = pkgs.callPackage ./pkgs/matrix-conduit.nix {};
}
