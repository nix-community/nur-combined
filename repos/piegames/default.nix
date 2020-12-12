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
{
	inherit lib modules overlays;
	# inherit (pkgsGnomeExtensions.gnomeExtensions)
	# 	buildShellExtension
	# 	# emoji-selector cpu-power-manager
	# 	# lock-screen-blur extension-reloader tray-icons
	# 	# dash-to-panel
	# 	;
	# buildShellExtension = pkgsGnomeExtensions.gnomeExtensions.buildShellExtension;
	
	matrix-conduit = pkgs.callPackage ./pkgs/matrix-conduit.nix {};
} // (let
	buildShellExtension2 = pkgs.callPackage ./pkgs/buildGnomeExtension2.nix {};
	extensions-index = builtins.fromJSON (builtins.readFile ./lib/extensions.json);
	extensions = builtins.map buildShellExtension2 extensions-index;
in
	(builtins.listToAttrs (builtins.map (e: {name = e.pname; value = e;}) extensions))
)
