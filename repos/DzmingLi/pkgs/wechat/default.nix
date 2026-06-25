{ stdenv, callPackage, wechat }:
# nixpkgs上linux版本的wechat采用wayback machine，有时会导致hash不一致
if stdenv.hostPlatform.isDarwin
then wechat
else callPackage ./linux.nix { }
