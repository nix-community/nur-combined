{ pkgs ? import <nixpkgs> { } }:
{
	eclecticlight = pkgs.lib.packagesFromDirectoryRecursive {
		inherit (pkgs) callPackage;
		directory = ./pkgs/eclectic-light;
	};

	daisydisk = pkgs.callPackage ./pkgs/daisydisk.nix {};
}
