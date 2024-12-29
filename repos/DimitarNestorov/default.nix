{ pkgs ? import <nixpkgs> { } }:
let
	eclecticlightPkgs = pkgs.lib.recurseIntoAttrs (
		pkgs.lib.packagesFromDirectoryRecursive {
			inherit (pkgs) callPackage;
			directory = ./pkgs/eclectic-light;
		}
	);
in {
	eclecticlight = eclecticlightPkgs // {
		skint-m = eclecticlightPkgs.skint.overrideAttrs {
			pname = "skint-m";
			app = "SkintM.app"; 
		};
		t2m2 = eclecticlightPkgs.the-time-machine-mechanic.overrideAttrs {
			pname = "t2m2";
		};
	};

	daisydisk = pkgs.callPackage ./pkgs/daisydisk.nix {};
}
