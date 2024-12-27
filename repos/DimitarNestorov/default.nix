{ pkgs ? import <nixpkgs> { } }:
let
	eclecticlightPkgs = pkgs.lib.packagesFromDirectoryRecursive {
		inherit (pkgs) callPackage;
		directory = ./pkgs/eclectic-light;
	};
in {
	eclecticlight = eclecticlightPkgs // {
		t2m2 = eclecticlightPkgs.the-time-machine-mechanic;
	};

	daisydisk = pkgs.callPackage ./pkgs/daisydisk.nix {};
}
