{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
	kotatogram-desktop = qt5.callPackage ./kotatogram-desktop {
		inherit libtgvoip rlottie-tdesktop;
	};
	libtgvoip = callPackage ./libtgvoip {};
	rlottie-tdesktop = callPackage ./rlottie-tdesktop {};
}
