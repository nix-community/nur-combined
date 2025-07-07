{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  myPkgs = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./pkgs;
  };
in
myPkgs
// {
  tsodingPackages = myPkgs.tsodingPackages // {
    blangFull = myPkgs.tsodingPackages.blang.override {
      windowsSupport = true;
      aarch64Support = true;
    };
  };
}
