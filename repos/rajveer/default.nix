{
	pkgs ? import <nixpkgs> { },
}:
let
	mkPackage = package: pkgs.callPackage ./pkgs/nixbox/package.nix { inherit package; };
in
{
	nixbox-tui = mkPackage "nixbox-tui";
	nixbox-cli = mkPackage "nixbox-cli";
}
// pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
	nixbox = mkPackage "nixbox";
	nixbox-gui = mkPackage "nixbox";
}
