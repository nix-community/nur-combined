{ stdenv, callPackage }:

# darwin（仅 Apple Silicon）走官方 mac .app（darwin.nix）；
# linux 走 deepin-wine10 bottle 版（linux.nix）。
if stdenv.hostPlatform.isDarwin
then callPackage ./darwin.nix { }
else callPackage ./linux.nix { }
