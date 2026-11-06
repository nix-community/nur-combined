{pkgs ? import <nixpkgs> {}}: {
  cheatmd = pkgs.callPackage ./pkgs/cheatmd {};
  operations = pkgs.callPackage ./pkgs/operations {};
  revshell = pkgs.callPackage ./pkgs/revshell {};
  steep = pkgs.callPackage ./pkgs/steep {};
}
