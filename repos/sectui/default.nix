{pkgs ? import <nixpkgs> {}}: {
  cheatmd = pkgs.callPackage ./pkgs/cheatmd {};
  operations = pkgs.callPackage ./pkgs/operations {};
}
