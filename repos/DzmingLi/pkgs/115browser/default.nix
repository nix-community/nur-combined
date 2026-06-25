{ stdenv, callPackage }:

if stdenv.hostPlatform.isDarwin
then callPackage ./darwin.nix { }
else callPackage ./linux.nix { }
